class ResearchersController < ApplicationController
  before_action :authorize_researcher
  before_action :set_researcher, only: [:show, :edit, :update]

  def show; end

  def edit; end

  def update
    if @researcher.update(researcher_params)
      render json: { success: true, redirect_url: researcher_path(id: EncryptionService.encrypt(@researcher.id)), message: 'Perfil atualizado com sucesso.' }
      return
    end

    flash.now.alert = 'Não foi possui atualizar o perfil'
    render partial: 'form_edit', locals: { researcher: @researcher }, status: :unprocessable_entity
  end

  private
  def researcher_params
    params.require(:researcher).permit(
      :name,
      :phone_number,
      :academic_field,
      :cv_link,
      :orcid_id,
      :academic_title,
      address_attributes: [
        :id,
        :street,
        :district,
        :complement,
        :postal_code,
        :city,
        :state
      ]
    )
  end
  def authorize_researcher
    unless current_user&.researcher? && current_user&.active? || current_user&.supervisor? && current_user&.active?
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end

  def set_researcher
    begin
      decrypted_id = EncryptionService.decrypt(params[:id])
      @researcher = Researcher.find(decrypted_id)
    rescue ActiveRecord::RecordNotFound
      @researcher = nil
      redirect_to root_path, alert: 'Pesquisador não encontrado'
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      redirect_to root_path, alert: 'ID inválido ou corrompido'
    end
  end
end
