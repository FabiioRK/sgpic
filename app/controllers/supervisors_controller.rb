class SupervisorsController < ApplicationController
  before_action :authorize_supervisor

  def index_coordinator
    @coordinators = Coordinator.joins(:user)
                               .order(active: :desc, created_at: :desc).page(params[:page]).per(10)
  end

  def index_researcher
    @researchers = Researcher.joins(:user)
                             .order(active: :desc, created_at: :desc).page(params[:page]).per(10)
  end

  def index_project
    @user_projects = Project.all
    @projects = filtered_projects.page(params[:page]).per(12)

    render :template => "projects/index"
  end

  def search_project
    @query = params["query"]

    @projects = Project.all

    if @query.present?
      @projects = @projects.joins(:student)
                           .where("CAST(projects.ric_number AS TEXT) LIKE :query OR LOWER(projects.project_title) LIKE :query OR LOWER(students.name) LIKE :query",
                                  query: "%#{@query.downcase}%")
                           .order(project_status: :asc, created_at: :desc)
    end

    @projects = @projects.page(params[:page]).per(12)

    render :template => "projects/index"
  end

  def show_project
    @project = Project.find(params[:id])

    render :template => "projects/show"
  end

  private

  def authorize_supervisor
    unless current_user&.supervisor? && current_user&.active?
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end

  def filtered_projects
    if params[:status].present? && Project.project_statuses.include?(params[:status])
      case params[:status]
      when 'aprovado', 'interrompido'
        @user_projects.where(project_status: params[:status]).order(feedback_date: :desc, project_status: :asc)
      else
        @user_projects.where(project_status: params[:status]).order(project_status: :asc, created_at: :desc)
      end
    else
      @user_projects.order(project_status: :asc, created_at: :desc)
    end
  end
end
