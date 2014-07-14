class PQProgressChangerService

  def update_progress(pq_before_save, pq_after_save)

    #  initial state 'Draft Pending' (done by the import process)

    pod_waiting_filter(pq_after_save, pq_before_save)
    pod_query_filter(pq_after_save, pq_before_save)
    pod_clearance_filter(pq_after_save, pq_before_save)
    minister_waiting_filter(pq_after_save, pq_before_save)
    minister_query_filter(pq_after_save, pq_before_save)
    minister_cleared_filter(pq_after_save, pq_before_save)

  end

  def pod_clearance_filter(pq_after_save, pq_before_save)
    if (pq_before_save.is_in_progress?(Progress.pod_waiting) || pq_before_save.is_in_progress?(Progress.pod_query)) && !pq_after_save.pod_clearance.nil?
      update_pq(pq_after_save, Progress.pod_cleared)
    end
  end

  def pod_query_filter(pq_after_save, pq_before_save)
    if pq_before_save.is_in_progress?(Progress.pod_waiting) && pq_after_save.pod_query_flag
      update_pq(pq_after_save, Progress.pod_query)
    end
  end

  def pod_waiting_filter(pq_after_save, pq_before_save)
    if pq_before_save.is_in_progress?(Progress.draft_pending) && !pq_after_save.draft_answer_received.nil?
      update_pq(pq_after_save, Progress.pod_waiting)
    end
  end


  def minister_waiting_filter(pq_after_save, pq_before_save)
    if !pq_before_save.is_in_progress?(Progress.pod_cleared)
      return
    end

    # does not have policy minister
    if pq_after_save.policy_minister.nil?
      if !pq_after_save.sent_to_answering_minister.nil?
        update_pq(pq_after_save, Progress.minister_waiting)
        return
      end
    end

    # has policy minister
    if !pq_after_save.sent_to_answering_minister.nil? && !pq_after_save.sent_to_policy_minister.nil?
      update_pq(pq_after_save, Progress.minister_waiting)
      return
    end
  end

  def minister_query_filter(pq_after_save, pq_before_save)
    if !pq_before_save.is_in_progress?(Progress.minister_waiting)
      return
    end

    # does not have policy minister
    if pq_after_save.policy_minister.nil?
      if pq_after_save.answering_minister_query
        update_pq(pq_after_save, Progress.minister_query)
        return
      end
    end

    # has policy minister
    if pq_after_save.policy_minister_query || pq_after_save.answering_minister_query
      update_pq(pq_after_save, Progress.minister_query)
      return
    end
  end


  def minister_cleared_filter(pq_after_save, pq_before_save)
    # not (minister_waiting || minister_query)
    if !(pq_before_save.is_in_progress?(Progress.minister_waiting) || pq_before_save.is_in_progress?(Progress.minister_query))
      return
    end

    # does not have policy minister
    if pq_after_save.policy_minister.nil?
      if !pq_after_save.cleared_by_answering_minister.nil?
        update_pq(pq_after_save, Progress.minister_cleared)
        return
      end
    end

    # has policy minister
    if !pq_after_save.cleared_by_answering_minister.nil? && !pq_after_save.cleared_by_policy_minister.nil?
      update_pq(pq_after_save, Progress.minister_cleared)
      return
    end
  end


  private
  def update_pq(pq, progress)
    pq.update(progress_id: progress.id)
  end


end