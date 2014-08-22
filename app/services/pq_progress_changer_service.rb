class PQProgressChangerService

  def update_progress(pq)
    #  initial state 'Draft Pending' (done by the import process)
    with_pod_filter(pq)
    pod_query_filter(pq)
    pod_clearance_filter(pq)
    with_minister_filter(pq)
    minister_query_filter(pq)
    minister_cleared_filter(pq)
    answered_filter(pq)
    transferred_out(pq)
  end

  def with_pod_filter(pq)
    if !pq.is_in_progress?(Progress.draft_pending)
      return
    end

    if !pq.draft_answer_received.nil?
      update_pq(pq, Progress.with_pod)
    end
  end

  def pod_query_filter(pq)
    if !pq.is_in_progress?(Progress.with_pod)
      return
    end

    if pq.pod_query_flag
      update_pq(pq, Progress.pod_query)
    end
  end

  def pod_clearance_filter(pq)
    # not (with_pod || pod_query)
    if !(pq.is_in_progress?(Progress.with_pod) || pq.is_in_progress?(Progress.pod_query))
      return
    end

    if !pq.pod_clearance.nil?
      update_pq(pq, Progress.pod_cleared)
    end
  end


  def with_minister_filter(pq)
    if !pq.is_in_progress?(Progress.pod_cleared)
      return
    end

    # does not have policy minister
    if pq.policy_minister.nil?
      if !pq.sent_to_answering_minister.nil?
        update_pq(pq, Progress.with_minister)
        return
      end
    end

    # has policy minister
    if !pq.sent_to_answering_minister.nil? && !pq.sent_to_policy_minister.nil?
      update_pq(pq, Progress.with_minister)
      return
    end
  end

  def minister_query_filter(pq)
    if !pq.is_in_progress?(Progress.with_minister)
      return
    end

    # does not have policy minister
    if pq.policy_minister.nil?
      if pq.answering_minister_query
        update_pq(pq, Progress.ministerial_query)
        return
      end
    end

    # has policy minister
    if pq.policy_minister_query || pq.answering_minister_query
      update_pq(pq, Progress.ministerial_query)
      return
    end
  end


  def minister_cleared_filter(pq)
    # not (with_minister || minister_query)
    if !(pq.is_in_progress?(Progress.with_minister) || pq.is_in_progress?(Progress.ministerial_query))
      return
    end

    # does not have policy minister & cleared by minister
    # Or has been cleared policy minister and not cleared by answering minister
    if pq_approved_by_minister_and_no_pol_minister(pq) || pq_approved_by_policy_minister(pq)
          update_pq(pq, Progress.minister_cleared)
          return
    end
  end


  def answered_filter(pq)
    if !pq.is_in_progress?(Progress.minister_cleared)
      return
    end

    if !pq.pq_withdrawn.nil?
      update_pq(pq, Progress.answered)
      return
    end

    if !pq.answer_submitted.nil?
      update_pq(pq, Progress.answered)
      return
    end

  end

  def transferred_out(pq)
    if !pq.transfer_out_ogd_id.nil? && !pq.transfer_out_date.nil?
      update_pq(pq, Progress.transferred_out)
      return
    end
  end

  private
  def update_pq(pq, progress)
    pq.update(progress_id: progress.id)
  end

  # PQ has no Policy minister and has been approved by Answering minister
  def pq_approved_by_minister_and_no_pol_minister(pq)
    pq.policy_minister.nil? && !pq.cleared_by_answering_minister.nil?
  end
  # PQ has been cleared by the policy minister and not been cleared by Answering minister
  def pq_approved_by_policy_minister(pq)
    !pq.cleared_by_answering_minister.nil? && !pq.cleared_by_policy_minister.nil?
  end
end