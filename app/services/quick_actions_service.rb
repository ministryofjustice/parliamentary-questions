class QuickActionsService
  include Validators::DateInput

  def valid?(pq_list, internal_deadline = "01/01/2000", draft_received = "01/01/2000" , pod_clearance = "01/01/2000", cleared_by_minister = "01/01/2000", answer_submitted = "01/01/2000")
    parse_datetime(internal_deadline) unless internal_deadline == ""
    parse_datetime(draft_received) unless draft_received == ""
    parse_datetime(pod_clearance) unless pod_clearance == ""
    parse_datetime(cleared_by_minister) unless cleared_by_minister == ""
    parse_datetime(answer_submitted) unless answer_submitted == ""
    valid_pq_list(pq_list)

  rescue DateTimeInputError
    false
  end

  def valid_pq_list(pq_list)
    pqs_array = Array.new
    pq_list.split(',').map { |p|
      real_pq = Pq.find_by(uin: p)
      if real_pq.nil?
        return false
      else
        pqs_array.push(real_pq)
      end
    }
    pqs_array
  end

  def update_pq_list(pq_list, internal_deadline, draft_received, pod_clearance, cleared_by_minister, answer_submitted)

    pq_batch = valid?(pq_list, internal_deadline, draft_received, pod_clearance, cleared_by_minister, answer_submitted)
    if pq_batch == false
      return
    end

    if internal_deadline and internal_deadline != ''
      pq_batch.each do |pq|
        pq.internal_deadline = internal_deadline
        pq.update_state!
        pq.save!
      end
    end
    if draft_received and draft_received != ''
      pq_batch.each do |pq|
        pq.draft_answer_received = draft_received
        pq.update_state!
      end
    end
    if pod_clearance and pod_clearance != ''
      pq_batch.each do |pq|
        pq.pod_clearance = pod_clearance
        pq.update_state!
      end
    end
    if cleared_by_minister and cleared_by_minister != ''
      pq_batch.each do |pq|
        pq.cleared_by_answering_minister = cleared_by_minister
        pq.update_state!
      end
    end
    if answer_submitted and answer_submitted != ''
      pq_batch.each do |pq|
        pq.answer_submitted = answer_submitted
        pq.update_state!
      end
    end
  end
end
