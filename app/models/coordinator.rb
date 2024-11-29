class Coordinator < ApplicationRecord
  belongs_to :user
  has_many :projects
  has_one :address
  accepts_nested_attributes_for :address


  validates :name, :academic_field, presence: true
  validates :phone_number, presence: true, format: { with: /\A\(\d{2}\) \d{5}-\d{4}\z/, message: "deve estar no formato (XX) XXXXX-XXXX" }, length: { is: 15 }
end
