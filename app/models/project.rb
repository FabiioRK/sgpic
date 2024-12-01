class Project < ApplicationRecord
  belongs_to :researcher
  belongs_to :coordinator
  belongs_to :notice
  has_one :student
  accepts_nested_attributes_for :student
  has_many :annotation_histories, dependent: :destroy
  has_many_attached :attachments
  attr_accessor :new_attachments

  enum project_type: {
    PIBIC: 0,
    PIBIC_CNPQ: 1,
    PIVITI: 2
  }

  enum project_status: {
    em_analise: 0,
    pendente: 1,
    aprovado: 5,
    interrompido: 9
  }

  validates :project_type, :institution, :course, :study_area, :research_line, :ods,
            :project_title, :project_summary, :key_words, presence: true
  validates :ric_number, presence: true, uniqueness: true, numericality: { only_integer: true }
  before_validation :generate_ric_number, on: :create
  validate :acceptable_attachment
  after_save :create_notifications, if: :saved_change_to_project_status?
  after_create :notify_new_project

  def create_notifications
    case project_status
    when 'em_analise'
      notify_researcher("O projeto nº '#{ric_number}' está em análise. Aguarde feedback do coordenador.")
      notify_coordinator("O projeto nº '#{ric_number}' foi atualizado e agora está em análise. Por favor, revise.")
    when 'pendente'
      notify_researcher("O projeto nº '#{ric_number}' possui pendências. Por favor, corrija-as para prosseguir.")
      notify_coordinator("O projeto nº '#{ric_number}' foi atualizado com pendências.")
    when 'aprovado'
      notify_coordinator("O projeto nº '#{ric_number}' foi aprovado com sucesso.")
      notify_researcher("Parabéns! O projeto nº '#{ric_number}' foi aprovado.")
      notify_supervisors("O projeto nº '#{ric_number}' foi aprovado e está disponível para supervisão.")
    when 'interrompido'
      notify_coordinator("O projeto nº '#{ric_number}' foi interrompido..")
      notify_researcher("O projeto nº '#{ric_number}' foi interrompido. Revise as razões para essa ação.")
      notify_supervisors("O projeto nº '#{ric_number}' foi interrompido e está disponível para supervisão.")
    end
  end

  def notify_new_project
    notify_coordinator("Você foi designado como o coordenador do projeto nº '#{ric_number}'. Por favor, inicie sua análise.")
    notify_researcher("O projeto nº '#{ric_number}' foi criado e está atualmente em análise pelo coordenador.")
    notify_supervisors("Um novo projeto foi cadastrado com o nº '#{ric_number}'. Acompanhe seu progresso para supervisão.")
  end

  private
  def generate_ric_number
    loop do
      ric = SecureRandom.random_number(9_999_999_999 - 1_000_000_000) + 1_000_000_000
      unless Project.exists?(ric_number: ric)
        self.ric_number = ric
        break
      end
    end
  end

  def acceptable_attachment
    if new_attachments.present?
      if new_attachments.size > 5
        errors.add(:base, "Você pode anexar no máximo 5 arquivos por vez.")
      end

      allowed_types = %w[
        application/pdf
        application/msword
        application/vnd.openxmlformats-officedocument.wordprocessingml.document
        application/zip
        image/png
        image/jpeg
      ]

      new_attachments.each do |file|
        unless file.content_type.in?(allowed_types)
          errors.add(:base, "Formato do arquivo '#{file.original_filename}' não permitido. Apenas PDF, DOCX, ZIP, PNG e JPEG são aceitos.")
        end

        if file.size > 10.megabytes
          errors.add(:base, "O arquivo '#{file.original_filename}' deve ter no máximo 10MB.")
        end
      end
    end
  end

  def notify_coordinator(message)
    return unless coordinator&.user&.active?

    Notification.create!(
      user: coordinator.user,
      project: self,
      message: message
    )
  end

  def notify_researcher(message)
    return unless researcher&.user&.active?

    Notification.create!(
      user: researcher.user,
      project: self,
      message: message
    )
  end

  def notify_supervisors(message)
    User.where(role: 'supervisor', active: true).find_each do |supervisor|
      Notification.create!(
        user: supervisor,
        project: self,
        message: message
      )
    end
  end

end
