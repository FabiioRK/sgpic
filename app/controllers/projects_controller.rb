class ProjectsController < ApplicationController
  before_action :authorize_access_view, only: [:index, :show, :search]
  before_action :authorize_researcher_create, only: [:new, :create]
  before_action :authorize_coordinator_researcher_update, only: [:edit, :update]
  before_action :project_accessible_by, only: [:show, :edit]

  def index
    @user_projects = case
                     when current_user.coordinator?
                       Project.where(coordinator: current_user.coordinator)
                     when current_user.researcher?
                       Project.where(researcher: current_user.researcher)
                     else
                       Project.none
                     end

    @projects = filtered_projects.page(params[:page]).per(12)
  end

  def show
    @project = Project.find(params[:id])
    @annotation_history = AnnotationHistory.where(project: @project).order(created_at: :desc)
  end

  def new
    @researcher = current_user.researcher
    @project = @researcher.projects.build
    @student = @project.build_student
    @student.build_address

    @coordinators = Coordinator.joins(:user).where(users: { active: true })
    @notices = Notice.where(active: true)
  end

  def create
    @researcher = current_user.researcher
    @project = @researcher.projects.build(project_params.except(:attachments))

    if params[:project][:attachments].present?
      new_attachments = params[:project][:attachments].reject(&:blank?)
      @project.new_attachments = new_attachments
    end

    if @project.save
      @project.attachments.attach(new_attachments) if new_attachments.present?
      render json: { success: true, redirect_url: determine_redirect_path, message: 'Projeto cadastrado com sucesso.' }
      return
    end

    @coordinators = Coordinator.joins(:user).where(users: { active: true })
    @notices = Notice.where(active: true)
    flash.now.alert = 'Não foi possível cadastrar o projeto'
    render partial: 'form_new', locals: { researcher: @researcher, project: @project, notices: @notices, coordinators: @coordinators }, status: :unprocessable_entity
  end

  def edit
    @coordinator = current_user.coordinator
    @researcher = current_user.researcher
    @project = Project.find(params[:id])
    @annotation_history = AnnotationHistory.where(project: @project).order(created_at: :desc)
  end

  def update
    @coordinator = current_user.coordinator
    @researcher = current_user.researcher
    @project = Project.find(params[:id])

    case
    when params[:interrupt_button]
      @project.project_status = 'interrompido'
      @project.feedback_date = Time.current
      update_params = project_params
    when params[:pending_button]
      @project.project_status = 'pendente'
      update_params = project_params.except(:annotation)
    when params[:update_button]
      @project.project_status = 'em_analise'
      update_params = project_params.except(:annotation)
    else
      @project.project_status = 'aprovado'
      @project.feedback_date = Time.current
      update_params = project_params
    end

    if params[:project][:attachments].present?
      new_attachments = (params[:project][:attachments] || []).reject(&:blank?)
      @project.new_attachments = new_attachments
      @project.attachments.attach(params[:project][:attachments])
    end

    if project_params[:annotation].blank?
      @annotation_history = AnnotationHistory.where(project: @project).order(created_at: :desc)
      @project.errors.add(:base, 'Anotação é obrigatório ao atualizar o projeto.')
      render partial: 'form_edit', locals: { project: @project, researcher: @researcher, annotation_history: @annotation_history }, status: :unprocessable_entity
      return
    end

    if @project.update(update_params.except(:attachments))
      if params[:pending_button] || params[:update_button]
        AnnotationHistory.create!(
          project: @project,
          annotation: project_params[:annotation],
          created_by: current_user.id,
          created_at: Time.current
        )
      end

      if current_user.coordinator?
        render json: { success: true, redirect_url: coordinator_project_path(@project), message: 'Projeto atualizado com sucesso.' }
        return
      elsif current_user.researcher?
        render json: { success: true, redirect_url: researcher_project_path(@project), message: 'Projeto atualizado com sucesso.' }
        return
      end
    end

    @annotation_history = AnnotationHistory.where(project: @project).order(created_at: :desc)
    flash.now.alert = 'Não foi possível atualizar o projeto.'
    render partial: 'form_edit', locals: { project: @project, researcher: @researcher, annotation_history: @annotation_history }, status: :unprocessable_entity
  end

  def search
    @query = params["query"]

    @projects = case
                when current_user.coordinator?
                  Project.where(coordinator: current_user.coordinator)
                when current_user.researcher?
                  Project.where(researcher: current_user.researcher)
                else
                  Project.none
                end

    if @query.present?
      @projects = @projects.joins(:student)
                           .where("CAST(projects.ric_number AS TEXT) LIKE :query OR LOWER(projects.project_title) LIKE :query OR LOWER(students.name) LIKE :query",
                                  query: "%#{@query.downcase}%")
                           .order(project_status: :asc, created_at: :desc)
    end

    @projects = @projects.page(params[:page]).per(12)

    render :template => "projects/index"
  end

  private

  def project_params
    params.require(:project).permit(
      :notice_id,
      :coordinator_id,
      :project_type,
      :institution,
      :course,
      :study_area,
      :research_line,
      :ods,
      :project_title,
      :project_summary,
      :key_words,
      :annotation,
      attachments: [],
      student_attributes: [
        :name,
        :social_security_number,
        :identity_card_number,
        :birth_date,
        :phone_number,
        :email,
        :academic_field,
        :course,
        :semester,
        :has_subject_dependencies,
        :is_regular_student,
        address_attributes: [
          :street,
          :district,
          :complement,
          :postal_code,
          :city,
          :state
        ]
      ]
    )
  end

  def authorize_access_view
    unless current_user&.active? && (current_user&.researcher? || current_user&.coordinator? || current_user&.supervisor?)
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end

  def authorize_researcher_create
    unless current_user&.researcher? && current_user&.active?
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end

  def authorize_coordinator_researcher_update
    @project = Project.find(params[:id])

    unless current_user&.coordinator? && current_user&.active? || current_user&.researcher? && current_user&.active? && @project.project_status == 'pendente'
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end

  def project_accessible_by
    @project = Project.find(params[:id])

    return if current_user && case current_user.role
                              when 'coordinator'
                                @project.coordinator == current_user.coordinator
                              when 'researcher'
                                @project.researcher == current_user.researcher
                              when 'supervisor'
                                true
                              else
                                false
                              end

    redirect_to root_path, alert: 'Acesso não autorizado'
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

  def determine_redirect_path
    case current_user.role
    when 'supervisor'
      supervisor_projects_path
    when 'coordinator'
      coordinator_projects_path
    when 'researcher'
      researcher_projects_path
    else
      root_path
    end
  end
end
