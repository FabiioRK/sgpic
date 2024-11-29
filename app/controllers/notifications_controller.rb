class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(5)
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
    redirect_to notifications_path, notice: "Notificação marcada como lida."
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true, updated_at: Time.current)
    redirect_to notifications_path, notice: 'Todas as notificações foram marcadas como lidas.'
  end
end
