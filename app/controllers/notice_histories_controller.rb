class NoticeHistoriesController < ApplicationController
  before_action :authorize_access
  before_action :set_notice_and_history

  def show
  end

  private

  def authorize_access
    unless current_user&.active? && (current_user&.coordinator? || current_user&.supervisor?)
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end

  def set_notice_and_history
    decrypted_notice_id = EncryptionService.decrypt(params[:notice_id])
    decrypted_history_id = EncryptionService.decrypt(params[:id])

    @notice = Notice.find(decrypted_notice_id)
    @history = @notice.notice_histories.find(decrypted_history_id)

    @history.changes_made = translate_changes(@history.changes_made)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Registro não encontrado'
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    redirect_to root_path, alert: 'Parâmetros inválidos ou corrompidos'
  end

  def translate_changes(changes)
    changes.transform_keys do |attribute|
      I18n.t("activerecord.attributes.notice.#{attribute}", default: attribute.humanize)
    end
  end
end