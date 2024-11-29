class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :project

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }

  after_create :send_email_notification

  def mark_as_read!
    update!(read: true)
  end

  private

  def send_email_notification
    return unless user.active? && user.email.present?

    NotificationMailer.notify_user(self).deliver_later
  end
end
