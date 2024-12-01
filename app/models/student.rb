class Student < ApplicationRecord
  belongs_to :project
  has_one :address
  accepts_nested_attributes_for :address

  validates :name, :social_security_number, :identity_card_number, :semester, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "inválido" }
  validates :phone_number, presence: true, format: { with: /\A\(\d{2}\) \d{5}-\d{4}\z/, message: "deve estar no formato (XX) XXXXX-XXXX" }, length: { is: 15 }
  validates :social_security_number, presence: true, format: { with: /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/, message: "deve estar no formato XXX.XXX.XXX-XX" }, length: { is: 14 }
  validate :birth_date_cannot_be_in_the_future

  private

  def birth_date_cannot_be_in_the_future
    if birth_date.present? && birth_date > Date.today
      errors.add(:base, "data inválida")
    end
  end
end
