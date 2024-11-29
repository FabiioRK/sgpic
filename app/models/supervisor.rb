class Supervisor < ApplicationRecord
  belongs_to :user
  has_one :address
  accepts_nested_attributes_for :address

  validates :name, presence: true, length: { maximum: 255 }
end
