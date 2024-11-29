class NoticeHistory < ApplicationRecord
  belongs_to :notice
  belongs_to :user, foreign_key: :edited_by, optional: false

  validates :edited_by, :changes_made, :edited_at, presence: true
end
