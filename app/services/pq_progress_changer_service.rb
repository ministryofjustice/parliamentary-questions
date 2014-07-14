class PQProgressChangerService

  def update_progress(pq)

    #  initial state 'Draft Pending' (done by the import process)
    pod_waiting_filter(pq)
    pod_query_filter(pq)
    pod_clearance_filter(pq)
    minister_waiting_filter(pq)
    minister_query_filter(pq)
    minister_cleared_filter(pq)
    answered_filter(pq)

  end

  def pod_clearance_filter(pq)
    # not (pod_waiting || pod_query)
    if !(pq.is_in_progress?(Progress.pod_waiting) || pq.is_in_progress?(Progress.pod_query))
      return
    end

    if !pq.pod_clearance.nil?
      update_pq(pq, Progress.pod_cleared)
    end
  end

  def pod_query_filter(pq)
    if !pq.is_in_progress?(Progress.pod_waiting)
      return
    end

    if pq.pod_query_flag
      update_pq(pq, Progress.pod_query)
    end
  end

  def pod_waiting_filter(pq)
    if !pq.is_in_progress?(Progress.draft_pending)
      return
    end

    if !pq.draft_answer_received.nil?
      update_pq(pq, Progress.pod_waiting)
    end
  end


  def minister_waiting_filter(pq)
    if !pq.is_in_progress?(Progress.pod_cleared)
      return
    end

    # does not have policy minister
    if pq.policy_minister.nil?
      if !pq.sent_to_answering_minister.nil?
        update_pq(pq, Progress.minister_waiting)
        return
      end
    end

    # has policy minister
    if !pq.sent_to_answering_minister.nil? && !pq.sent_to_policy_minister.nil?
      update_pq(pq, Progress.minister_waiting)
      return
    end
  end

  def minister_query_filter(pq)
    if !pq.is_in_progress?(Progress.minister_waiting)
      return
    end

    # does not have policy minister
    if pq.policy_minister.nil?
      if pq.answering_minister_query
        update_pq(pq, Progress.minister_query)
        return
      end
    end

    # has policy minister
    if pq.policy_minister_query || pq.answering_minister_query
      update_pq(pq, Progress.minister_query)
      return
    end
  end


  def minister_cleared_filter(pq)
    # not (minister_waiting || minister_query)
    if !(pq.is_in_progress?(Progress.minister_waiting) || pq.is_in_progress?(Progress.minister_query))
      return
    end

    # does not have policy minister
    if pq.policy_minister.nil?
      if !pq.cleared_by_answering_minister.nil?
        update_pq(pq, Progress.minister_cleared)
        return
      end
    end

    # has policy minister
    if !pq.cleared_by_answering_minister.nil? && !pq.cleared_by_policy_minister.nil?
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


  private
  def update_pq(pq, progress)
    pq.update(progress_id: progress.id)
  end


end