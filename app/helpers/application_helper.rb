module ApplicationHelper
  def flash_class_for(flash_type)
    case flash_type.to_s
    when "notice"
      # We set success msg for notice as well as success
      "pq-msg-success"
    when "success"
      "pq-msg-success"
    when "error"
      "pq-msg-error"
    when "alert"
      "pq-msg-warning"
    else
      "pq-msg-success"
    end
  end

  def state_classname(classname)
    classname.tr("_", "-")
  end

  def state_label(label)
    PQState.state_label(label)
  end

  def minister_warning?(question, minister)
    !!(question.present? && question.open? && minister.try(:deleted?))
  end

  def action_officer_toggle_link(show_inactive)
    if show_inactive
      link_to "View active action officers", action_officers_path, { class: "button-secondary" }
    else
      link_to "View inactive action officers", action_officers_path(show_inactive: true), { class: "button-secondary" }
    end
  end

  def feature_propose_ao_enabled?
    !!Rails.application.config.feature_propose_ao_enabled || Rails.env.test?
  end
end
