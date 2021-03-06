module ApplicationHelper
  def flash_class_for(flash_type)
    case flash_type.to_s
    when 'notice'
      # We set success msg for notice as well as success
      'pq-msg-success'
    when 'success'
      'pq-msg-success'
    when 'error'
      'pq-msg-error'
    when 'alert'
      'pq-msg-warning'
    else
      'pq-msg-success'
    end
  end

  def state_classname(s)
    s.tr('_', '-')
  end

  def state_label(s)
    PQState.state_label(s)
  end

  def minister_warning?(question, minister)
    !!(question.present? && question.open? && minister.try(:deleted?))
  end
end
