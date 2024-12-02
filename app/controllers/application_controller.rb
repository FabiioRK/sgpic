class ApplicationController < ActionController::Base
  before_action :check_session_timeout
  helper_method :search_path_for_role, :profile_path_for_role

  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from Warden::NotAuthenticated, with: :render_not_found

  def render_not_found
    render "errors/not_found", status: :not_found
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def search_path_for_role(user)
    case user.role
    when 'supervisor'
      search_supervisor_projects_path
    when 'coordinator'
      search_coordinator_projects_path(user.coordinator)
    when 'researcher'
      search_researcher_projects_path(user.researcher)
    else
      root_path
    end
  end

  def profile_path_for_role(user)
    case user.role
    when 'coordinator'
      coordinator_path(id: EncryptionService.encrypt(user.coordinator.id))
    when 'researcher'
      researcher_path(id: EncryptionService.encrypt(user.researcher.id))
    else
      root_path
    end
  end


  private

  def check_session_timeout
    if user_signed_in?
      if session[:last_seen].present?
        last_seen_time = Time.parse(session[:last_seen]) rescue nil

        if last_seen_time && Time.now - last_seen_time > 30.minutes
          reset_session
          unless user_signed_in?
            redirect_to new_user_session_path, alert: "Sua sessão expirou. Por favor, faça login novamente."
          end
        else
          session[:last_seen] = Time.now.to_s
        end

      else
        session[:last_seen] = Time.now.to_s
      end
    end
  end

end
