module ApplicationHelper
  def required_label(attribute, model = nil)
    model ||= attribute.to_s.split('_').first

    label = I18n.t("activerecord.attributes.#{model}.#{attribute}", default: attribute.to_s.humanize)

    "#{label} <span class='text-danger'>*</span>".html_safe
  end
end

