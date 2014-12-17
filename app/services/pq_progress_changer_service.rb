class PQProgressChangerService
  def update_progress(pq)
    @new_progress = pq.progress
    @progress_onwards = true

    unassigned_filter(pq)
    commissioned_filter(pq) if @progress_onwards
    rejected_filter(pq) if @progress_onwards
    draft_pending_filter(pq) if @progress_onwards
    with_pod_filter(pq) if @progress_onwards
    pod_query_filter(pq) if @progress_onwards
    pod_clearance_filter(pq) if @progress_onwards
    with_minister_filter(pq) if @progress_onwards
    minister_query_filter(pq) if @progress_onwards
    minister_cleared_filter(pq) if @progress_onwards
    answered_filter(pq) if @progress_onwards
    transferred_out(pq)

    update_pq(pq, @new_progress)
  end
  def unassigned_filter(pq)
    if pq.is_unallocated?
      @new_progress = Progress.unassigned
      @progress_onwards = false
    end
  end

  def commissioned_filter(pq)
    if pq.commissioned?
      @new_progress = Progress.no_response
    end
  end

  def rejected_filter(pq)
    if pq.action_officers_pqs.all_rejected?
      @new_progress = Progress.rejected
    end
  end

  def draft_pending_filter(pq)
    if pq.action_officer_accepted.present?
      @new_progress = Progress.draft_pending
    else
      @progress_onwards = false
    end
  end

  def with_pod_filter(pq)
    if !pq.draft_answer_received.nil?
      @new_progress =  Progress.with_pod
    else
      @progress_onwards = false
    end
  end

  def pod_query_filter(pq)
    if pq.pod_query_flag
      @new_progress =  Progress.pod_query
    end
  end

  def pod_clearance_filter(pq)
    if !(!pq.draft_answer_received.nil? || pq.pod_query_flag)
      return
    end

    if !pq.pod_clearance.nil?
      @new_progress =  Progress.pod_cleared
    else
      @progress_onwards = false
    end
  end


  def with_minister_filter(pq)
    if pq.policy_minister.nil?
      if !pq.sent_to_answering_minister.nil?
        @new_progress =  Progress.with_minister
        return
      else
        @progress_onwards = false
      end
    end

    if !pq.sent_to_answering_minister.nil? && !pq.sent_to_policy_minister.nil?
      @new_progress =  Progress.with_minister
      @progress_onwards = true
      return
    else
      @progress_onwards = false
    end
  end

  def minister_query_filter(pq)
    if pq.policy_minister.nil?
      if pq.answering_minister_query
        @new_progress =  Progress.ministerial_query
        return
      end
    end

    if pq.policy_minister_query || pq.answering_minister_query
      @new_progress = Progress.ministerial_query
      progress_onwards = true
      return
    end
  end

  def minister_cleared_filter(pq)
    if pq_approved_by_minister_and_no_pol_minister(pq) || pq_approved_by_policy_minister(pq)
      @new_progress =  Progress.minister_cleared
      return
    else
      @progress_onwards = false
    end
  end

  def answered_filter(pq)
    if !pq.pq_withdrawn.nil?
      @new_progress =   Progress.answered
      return
    else
      @progress_onwards = false
    end

    if !pq.answer_submitted.nil?
      @new_progress =  Progress.answered
      return
    else
      @progress_onwards = false
    end
  end

  def transferred_out(pq)
    if !pq.transfer_out_ogd_id.nil? && !pq.transfer_out_date.nil?
      @new_progress =  Progress.transferred_out
      return
    end
  end

private

  def update_pq(pq, progress)
    pq.update(progress_id: progress.id)
  end

  def pq_approved_by_minister_and_no_pol_minister(pq)
    pq.policy_minister.nil? && !pq.cleared_by_answering_minister.nil?
  end

  def pq_approved_by_policy_minister(pq)
    !pq.cleared_by_answering_minister.nil? && !pq.cleared_by_policy_minister.nil?
  end
end
