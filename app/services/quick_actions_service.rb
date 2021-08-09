class QuickActionsService
  include Validators::DateInput

  def valid?(pq_list, internal_deadline = '01/01/2000', draft_received = '01/01/2000', pod_clearance = '01/01/2000', cleared_by_minister = '01/01/2000', answer_submitted = '01/01/2000')
    parse_datetime(internal_deadline) unless internal_deadline == ''
    parse_datetime(draft_received) unless draft_received == ''
    parse_datetime(pod_clearance) unless pod_clearance == ''
    parse_datetime(cleared_by_minister) unless cleared_by_minister == ''
    parse_datetime(answer_submitted) unless answer_submitted == ''
    valid_pq_list(pq_list)
  rescue DateTimeInputError
    false
  end

  def valid_pq_list(pq_list)
    pqs_array = []
    pq_list.split(',').map do |p|
      real_pq = Pq.find_by(uin: p)
      return false if real_pq.nil?

      pqs_array.push(real_pq)
    end
    pqs_array
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def update_pq_list(pq_list, internal_deadline, draft_received, pod_clearance, cleared_by_minister, answer_submitted)
    pq_batch = valid?(pq_list, internal_deadline, draft_received, pod_clearance, cleared_by_minister, answer_submitted)
    return if pq_batch == false

    if internal_deadline && internal_deadline != ''
      pq_batch.each do |pq|
        pq.internal_deadline = internal_deadline
        pq.update_state!
        pq.save!
      end
    end
    if draft_received && draft_received != ''
      pq_batch.each do |pq|
        pq.draft_answer_received = draft_received
        pq.update_state!
      end
    end
    if pod_clearance && pod_clearance != ''
      pq_batch.each do |pq|
        pq.pod_clearance = pod_clearance
        pq.update_state!
      end
    end
    if cleared_by_minister && cleared_by_minister != ''
      pq_batch.each do |pq|
        pq.cleared_by_answering_minister = cleared_by_minister
        pq.update_state!
      end
    end
    if answer_submitted && answer_submitted != ''
      pq_batch.each do |pq|
        pq.answer_submitted = answer_submitted
        pq.update_state!
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def get_action_officer_pqs_id(pq)
    ao_pq = pq.action_officers_pqs.find(&:accepted?)
    ao_pq&.id
  end

  def mail_reminders(pqs)
    pqs.each do |pq|
      ao_pq_id = get_action_officer_pqs_id(pq)
      next if ao_pq_id.nil?

      ao_pq = ActionOfficersPq.find(ao_pq_id)
      if ao_pq.action_officer.group_email.present?
        NotifyPqMailer.draft_reminder_email(pq: pq, action_officer: ao_pq.action_officer, email: ao_pq.action_officer.group_email).deliver_later
      end
      NotifyPqMailer.draft_reminder_email(pq: pq, action_officer: ao_pq.action_officer, email: ao_pq.action_officer.email).deliver_later
      ao_pq.increment(:reminder_draft).save
    end
  end

  def mail_draft_list(pq_list)
    mail_reminders(valid_pq_list(pq_list))
  end
end
