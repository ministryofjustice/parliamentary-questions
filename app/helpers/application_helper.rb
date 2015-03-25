module ApplicationHelper
  def flash_class_for(flash_type)
    case flash_type.to_s
    when 'notice'
      'pq-msg-success' # We set success msg for notice as well as success
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

  def minister_warning?(question, minister)
    question.present? && question.open? && minister.try(:deleted?)
  end
end
