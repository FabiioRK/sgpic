class Researcher < ApplicationRecord
  belongs_to :user
  has_one :address
  has_many :projects
  accepts_nested_attributes_for :projects
  accepts_nested_attributes_for :address

  validates :name, :academic_field, :cv_link, :orcid_id, :academic_title, presence: true
  validates :phone_number, presence: true, format: { with: /\A\(\d{2}\) \d{5}-\d{4}\z/, message: "deve estar no formato (XX) XXXXX-XXXX" }, length: { is: 15 }
end
