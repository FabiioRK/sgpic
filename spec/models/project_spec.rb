require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:notice) { create(:notice, start_date: 2.days.from_now, end_date: 1.month.from_now) }

  describe 'validações' do
    it 'é válido com atributos válidos e um edital associado' do
      project = build(:project, researcher: create(:researcher), coordinator: create(:coordinator), notice: notice)
      expect(project).to be_valid
    end

    it 'não é válido sem um edital associado' do
      project = build(:project, researcher: create(:researcher), coordinator: create(:coordinator), notice: nil)
      expect(project).to_not be_valid
      expect(project.errors[:notice]).to include("é obrigatório(a)")
    end

    it 'não é válido com um número RIC duplicado' do
      project1 = create(:project, ric_number: 1234567890, researcher: create(:researcher), coordinator: create(:coordinator), notice: notice)

      allow_any_instance_of(Project).to receive(:generate_ric_number)

      project2 = build(:project, ric_number: project1.ric_number, researcher: create(:researcher), coordinator: create(:coordinator), notice: notice)

      expect(project2).to_not be_valid
      expect(project2.errors[:ric_number]).to include("já está em uso")
    end

    it 'gera um novo número RIC em caso de conflito' do
      existing_ric = 1234567890
      create(:project, ric_number: existing_ric, researcher: create(:researcher), coordinator: create(:coordinator), notice: notice)

      project = create(:project, researcher: create(:researcher), coordinator: create(:coordinator), notice: notice)

      expect(project.ric_number).to_not eq(existing_ric)
    end
  end

  describe 'notificações' do
    let(:notice) { create(:notice, start_date: 2.days.from_now, end_date: 1.month.from_now) }
    let(:project) { create(:project, researcher: create(:researcher), coordinator: create(:coordinator), notice: notice) }

    before do
      create_list(:user, 3, :supervisor, active: true)
    end

    it 'notifica supervisores na criação do projeto' do
      supervisors = User.where(role: 'supervisor', active: true)
      supervisor_notifications_creation = Notification.where(user: supervisors, project: project)

      expect(supervisor_notifications_creation.count).to eq(3)
    end

    it 'notifica pesquisador e coordenador na criação do projeto' do
      researcher_notifications = Notification.where(user: project.researcher.user, project: project)
      coordinator_notifications = Notification.where(user: project.coordinator.user, project: project)

      expect(researcher_notifications.count).to eq(1)
      expect(coordinator_notifications.count).to eq(1)
    end

    it 'não cria notificações duplicadas para o mesmo status' do
      project.update!(project_status: 'aprovado')
      initial_notifications_count = Notification.count

      # Atualiza para o mesmo status novamente
      project.update!(project_status: 'aprovado')
      new_notifications_count = Notification.count

      # Nenhuma notificação adicional deve ser criada
      expect(new_notifications_count).to eq(initial_notifications_count)
    end

    it 'cria notificações apropriadas ao alterar o status para pendente' do
      project.update!(project_status: 'pendente')

      researcher_notifications = Notification.where(user: project.researcher.user, project: project)
      coordinator_notifications = Notification.where(user: project.coordinator.user, project: project)

      expect(researcher_notifications.last.message).to eq("O projeto nº '#{project.ric_number}' possui pendências. Por favor, corrija-as para prosseguir.")
      expect(coordinator_notifications.last.message).to eq("O projeto nº '#{project.ric_number}' foi atualizado com pendências.")
    end

    it 'notifica supervisores, coordenador e pesquisador ao alterar status para interrompido' do
      supervisors = User.where(role: 'supervisor', active: true)
      expect(supervisors.count).to eq(3)

      project = create(:project, researcher: create(:researcher), coordinator: create(:coordinator), notice: notice)

      supervisor_notifications_initial = Notification.where(user: supervisors, project: project)
      coordinator_notifications_initial = Notification.where(user: project.coordinator.user, project: project)
      researcher_notifications_initial = Notification.where(user: project.researcher.user, project: project)
      expect(supervisor_notifications_initial.count).to eq(3)
      expect(coordinator_notifications_initial.count).to eq(1)
      expect(researcher_notifications_initial.count).to eq(1)

      project.update!(project_status: 'interrompido')

      supervisor_notifications_after_update = Notification.where(user: supervisors, project: project)
      coordinator_notifications_after_update = Notification.where(user: project.coordinator.user, project: project)
      researcher_notifications_after_update = Notification.where(user: project.researcher.user, project: project)

      expect(supervisor_notifications_after_update.count).to eq(6)
      expect(coordinator_notifications_after_update.count).to eq(2)
      expect(researcher_notifications_after_update.count).to eq(2)

      total_notifications = Notification.where(project: project)
      expect(total_notifications.count).to eq(10) # 6 (supervisores) + 2 (coordenador) + 2 (pesquisador)
    end


    it 'notifica corretamente ao mudar status várias vezes' do
      project.update!(project_status: 'pendente')
      project.update!(project_status: 'aprovado')
      project.update!(project_status: 'interrompido')

      supervisors = User.where(role: 'supervisor', active: true)
      supervisor_notifications = Notification.where(user: supervisors, project: project)
      coordinator_notifications = Notification.where(user: project.coordinator.user, project: project)
      researcher_notifications = Notification.where(user: project.researcher.user, project: project)

      expect(supervisor_notifications.count).to eq(9) # 3 notificações iniciais (criação) + 3 (aprovado) + 3 (interrompido)
      expect(coordinator_notifications.count).to eq(4) # 1 notificação inicial + 1 (pendente) + 1 (aprovado) + 1 (interrompido)
      expect(researcher_notifications.count).to eq(4) # 1 notificação inicial + 1 (pendente) + 1 (aprovado) + 1 (interrompido)

      total_notifications = Notification.where(project: project)
      expect(total_notifications.count).to eq(17) # 9 (supervisores) + 3 (coordenador) + 3 (pesquisador)
    end

  end


  describe 'validação de anexos' do
    let(:project) { build(:project) }

    it 'permite anexar até 5 arquivos válidos' do
      valid_files = Array.new(5) { fixture_file_upload('spec/fixtures/files/test.pdf', 'application/pdf') }
      project.new_attachments = valid_files
      expect(project).to be_valid
    end

    it 'não permite mais de 5 arquivos' do
      invalid_files = Array.new(6) { fixture_file_upload('spec/fixtures/files/test.pdf', 'application/pdf') }
      project.new_attachments = invalid_files
      expect(project).to_not be_valid
      expect(project.errors[:base]).to include("Você pode anexar no máximo 5 arquivos por vez.")
    end

    it 'não permite arquivos com tipos inválidos' do
      invalid_files = [fixture_file_upload('spec/fixtures/files/invalid_file.txt', 'text/plain')]
      project.new_attachments = invalid_files
      expect(project).to_not be_valid
      expect(project.errors[:base]).to include("Formato do arquivo 'invalid_file.txt' não permitido. Apenas PDF, DOCX, ZIP, PNG e JPEG são aceitos.")
    end

    it 'não permite arquivos maiores que 10MB' do
      large_file = fixture_file_upload('spec/fixtures/files/large_file.pdf', 'application/pdf')
      allow(large_file).to receive(:size).and_return(11.megabytes)
      project.new_attachments = [large_file]
      expect(project).to_not be_valid
      expect(project.errors[:base]).to include("O arquivo 'large_file.pdf' deve ter no máximo 10MB.")
    end
  end

  describe 'enumerações' do
    it 'aceita apenas tipos de projeto válidos' do
      expect(Project.project_types.keys).to include('PIBIC', 'PIBIC_CNPQ', 'PIVITI')
    end

    it 'aceita apenas status de projeto válidos' do
      expect(Project.project_statuses.keys).to include('em_analise', 'pendente', 'aprovado', 'interrompido')
    end
  end

  describe 'relacionamentos' do
    it { should belong_to(:researcher) }
    it { should belong_to(:coordinator) }
    it { should belong_to(:notice) }
    it { should have_one(:student) }
    it { should accept_nested_attributes_for(:student) }
    it { should have_many(:annotation_histories).dependent(:destroy) }
  end

  describe 'callbacks' do
    it 'gera um número RIC antes da validação' do
      project = build(:project, ric_number: nil, researcher: create(:researcher), coordinator: create(:coordinator), notice: notice)
      project.valid?
      expect(project.ric_number).to_not be_nil
    end
  end
end
