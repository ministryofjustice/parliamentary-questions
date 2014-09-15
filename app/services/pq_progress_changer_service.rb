class PQProgressChangerService

  def update_progress(pq)

    @new_progress = Progress.draft_pending
    @progress_onwards = TRUE


    #  initial state 'Draft Pending' (done by the import process)
    with_pod_filter(pq) if @progress_onwards
    puts "with_pod_filter ?         : " + @new_progress.name + "  Onwards?" + @progress_onwards.to_s
    pod_query_filter(pq) if @progress_onwards
    puts "pod_query_filter ?        : " + @new_progress.name + "  Onwards?" + @progress_onwards.to_s
    pod_clearance_filter(pq) if @progress_onwards
    puts "pod_clearance_filter ?    : " + @new_progress.name + "  Onwards?" + @progress_onwards.to_s
    with_minister_filter(pq) if @progress_onwards
    puts "with_minister_filter ?    : " + @new_progress.name + "  Onwards?" + @progress_onwards.to_s
    minister_query_filter(pq) if @progress_onwards
    puts "minister_query_filter ?   : " + @new_progress.name + "  Onwards?" + @progress_onwards.to_s
    minister_cleared_filter(pq) if @progress_onwards
    puts "minister_cleared_filter ? : " + @new_progress.name + "  Onwards?" + @progress_onwards.to_s
    answered_filter(pq) if @progress_onwards
    puts "answered_filter ?         : " + @new_progress.name + "  Onwards?" + @progress_onwards.to_s
    transferred_out(pq) # Always check transferred out.
    puts "transferred_out ?         : " + @new_progress.name + "  Onwards?" + @progress_onwards.to_s

    update_pq(pq, @new_progress)

  end

  def with_pod_filter(pq)
    # if !pq.is_in_progress?(Progress.draft_pending)
    #   return
    # end

    if !pq.draft_answer_received.nil?
      @new_progress =  Progress.with_pod
    else
      @progress_onwards = FALSE
    end

  end

  def pod_query_filter(pq)
    # if !pq.is_in_progress?(Progress.with_pod)
    #   return
    # end

    if pq.pod_query_flag
      @new_progress =  Progress.pod_query
    # else
    #   @progress_onwards = FALSE
    end
  end

  def pod_clearance_filter(pq)
    # not (with_pod || pod_query)
    # if !(pq.is_in_progress?(Progress.with_pod) || pq.is_in_progress?(Progress.pod_query))
    #   return
    # end

    if !(!pq.draft_answer_received.nil? || pq.pod_query_flag)
      return
    end

    if !pq.pod_clearance.nil?
      @new_progress =  Progress.pod_cleared
    else
      @progress_onwards = FALSE
    end
  end


  def with_minister_filter(pq)
    # if !pq.is_in_progress?(Progress.pod_cleared)
    #   return
    # end


    # does not have policy minister
    if pq.policy_minister.nil?
      if !pq.sent_to_answering_minister.nil?
        @new_progress =  Progress.with_minister
        return
      else
        @progress_onwards = FALSE
      end
    end

    # has policy minister
    if !pq.sent_to_answering_minister.nil? && !pq.sent_to_policy_minister.nil?
      @new_progress =  Progress.with_minister
      @progress_onwards = TRUE
      return
    else
      @progress_onwards = FALSE
    end
  end

  def minister_query_filter(pq)
    # if !pq.is_in_progress?(Progress.with_minister)
    #   return
    # end


    # does not have policy minister
    if pq.policy_minister.nil?
      if pq.answering_minister_query
        @new_progress =  Progress.ministerial_query
        return
      # else
      #   @progress_onwards = FALSE
      end
    end

    # has policy minister
    if pq.policy_minister_query || pq.answering_minister_query
      @new_progress = Progress.ministerial_query
      progress_onwards = TRUE
      return
    # else
    #   @progress_onwards = FALSE
    end
  end


  def minister_cleared_filter(pq)
    # not (with_minister || minister_query)
    # if !(pq.is_in_progress?(Progress.with_minister) || pq.is_in_progress?(Progress.ministerial_query))
    #   return
    # end

    # does not have policy minister & cleared by minister
    # Or has been cleared policy minister and not cleared by answering minister
    if pq_approved_by_minister_and_no_pol_minister(pq) || pq_approved_by_policy_minister(pq)
      @new_progress =  Progress.minister_cleared
      return
    else
      @progress_onwards = FALSE
    end
  end


  def answered_filter(pq)
    # if !pq.is_in_progress?(Progress.minister_cleared)
    #   return
    # end

    if !pq.pq_withdrawn.nil?
      @new_progress =   Progress.answered
      return
    else
      @progress_onwards = FALSE
    end

    if !pq.answer_submitted.nil?
      @new_progress =  Progress.answered
      return
    else
      @progress_onwards = FALSE
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

  # PQ has no Policy minister and has been approved by Answering minister
  def pq_approved_by_minister_and_no_pol_minister(pq)
    pq.policy_minister.nil? && !pq.cleared_by_answering_minister.nil?
  end
  # PQ has been cleared by the policy minister and not been cleared by Answering minister
  def pq_approved_by_policy_minister(pq)
    !pq.cleared_by_answering_minister.nil? && !pq.cleared_by_policy_minister.nil?
  end
  end
