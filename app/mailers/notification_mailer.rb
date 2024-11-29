class NotificationMailer < ApplicationMailer
  default from: ENV['EMAIL_USERNAME']

  def notify_user(notification)
    @notification = notification
    @user = notification.user
    @project = notification.project

    @path = case @user.role
            when 'supervisor' then supervisor_project_url(@project)
            when 'coordinator' then coordinator_project_url(@project.coordinator, @project)
            when 'researcher' then researcher_project_url(@project.researcher, @project)
            end

    mail(
      to: @user.email,
      subject: "Nova notificação: #{@notification.message}"
    )
  end
end
