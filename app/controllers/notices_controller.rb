class NoticesController < ApplicationController
  before_action :authorize_access

  def index
    @notices = filtered_notices.page(params[:page]).per(5)
  end

  def show
    decrypted_id = EncryptionService.decrypt(params[:id])
    @notice = Notice.find(decrypted_id)
  end

  def new
    @notice = Notice.new
  end

  def create
    @notice = Notice.new(notice_params)
    @notice.created_by = current_user.id

    if @notice.save
      render json: { success: true, redirect_url: notices_path, message: 'Edital criado com sucesso.' }
      return
    end

    flash.now.alert = 'Não foi possível cadastrar o edital.'
    render partial: 'form', locals: { notice: @notice }, status: :unprocessable_entity
  end

  def edit
    decrypted_id = EncryptionService.decrypt(params[:id])
    @notice = Notice.find(decrypted_id)
  end

  def update
    decrypted_id = EncryptionService.decrypt(params[:id])
    @notice = Notice.find(decrypted_id)

    if @notice.update(notice_params)
      changes_made = @notice.saved_changes.slice(*notice_params.keys)

      if changes_made.present?
        NoticeHistory.create!(
          notice: @notice,
          edited_by: current_user.id,
          changes_made: changes_made,
          edited_at: Time.current
        )
      end

      render json: { success: true, redirect_url: notice_path(id: EncryptionService.encrypt(@notice.id)), message: 'Edital atualizado com sucesso.' }
      return
    end

    flash.now.alert = 'Não foi possível atualizar o edital.'
    render partial: 'form', locals: { notice: @notice }, status: :unprocessable_entity
  end

  def destroy
    decrypted_id = EncryptionService.decrypt(params[:id])
    @notice = Notice.find(decrypted_id)

    if @notice.destroy
      render json: { success: true, redirect_url: notices_path, message: "Edital excluído com sucesso." }
    else
      render json: { success: false, message: "Não foi possível excluir o edital." }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: "Edital não encontrado." }, status: :ok
  rescue ActiveRecord::InvalidForeignKey
    render json: { success: false, message: "Não é possível excluir o edital porque ele está vinculado a projetos." }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { success: false, message: "Erro interno no servidor: #{e.message}" }, status: :internal_server_error
  end

  def toggle_active
    decrypted_id = EncryptionService.decrypt(params[:id])
    @notice = Notice.find(decrypted_id)

    if @notice.update(active: !@notice.active)
      render json: { success: true, message: 'Status do edital atualizado com sucesso.' }
    else
      flash[:validation_errors] = @notice.errors.full_messages
      render json: { success: false, message: 'Não foi possível atualizar o status do edital.' }, status: :unprocessable_entity
    end
  end


  def history
    decrypted_id = EncryptionService.decrypt(params[:id])
    @notice = Notice.find(decrypted_id)
    @histories = @notice.notice_histories.order(edited_at: :desc).page(params[:page]).per(5)
  end

  private
  def notice_params
    params.require(:notice).permit(
      :name,
      :start_date,
      :end_date,
      :description,
      :created_by
    )
  end

  def authorize_access
    if current_user&.coordinator? && current_user&.active? || current_user&.supervisor? && current_user&.active?
      nil
    elsif current_user&.researcher? && current_user.active?
      if %w[index show].include?(action_name)
        return
      else
        redirect_to notices_path, alert: 'Acesso não autorizado'
      end
    else
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end


  def filtered_notices
    notices = Notice.all.order(active: :desc,start_date: :desc)

    if params[:active].present?
      case params[:active].downcase
      when 'ativo'
        notices = notices.where(active: true)
      when 'inativo'
        notices = notices.where(active: false)
      end
    end

    notices
  end


end
