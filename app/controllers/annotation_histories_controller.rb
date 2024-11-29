class AnnotationHistoriesController < ApplicationController
  before_action :authorize_user
  before_action :annotation_accessible_by
  def show
    @project = Project.find(params[:project_id])
    @annotation_history = AnnotationHistory.where(project: @project).order(created_at: :desc)
  end

  private

  def annotation_accessible_by
    @project = Project.find(params[:project_id])

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

  def authorize_user
    unless current_user&.active? && (current_user&.coordinator? || current_user&.supervisor? || current_user&.researcher)
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end

end
