class Address < ApplicationRecord
  has_one :supervisor
  has_one :coordinator
  has_one :researcher

  validates :street, :district, :postal_code, :city, :state, presence: true
  validates :postal_code, presence: true, format: { with: /\A\d{5}-\d{3}\z/, message: "deve estar no formato XXXXX-XXX" }, length: { is: 9 }
end
