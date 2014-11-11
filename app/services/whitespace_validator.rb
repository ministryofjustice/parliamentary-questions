class WhitespaceValidator
  def before_validation(record)
    record.name = record.name.strip unless record.name.nil?
    record.email = record.email.strip unless record.email.nil?
    record.group_email = record.group_email.strip unless !record.has_attribute?('group_email') || record.group_email.nil?
  end
end
