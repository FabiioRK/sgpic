class AnnotationHistory < ApplicationRecord
  belongs_to :project
  belongs_to :user, foreign_key: :created_by, optional: false

  validates :created_by, presence: true
end
