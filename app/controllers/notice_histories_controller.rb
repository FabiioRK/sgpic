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
    @notice = Notice.find(params[:notice_id])
    @history = @notice.notice_histories.find(params[:id])

    @history.changes_made = translate_changes(@history.changes_made)
  end

  def translate_changes(changes)
    changes.transform_keys do |attribute|
      I18n.t("activerecord.attributes.notice.#{attribute}", default: attribute.humanize)
    end
  end
end