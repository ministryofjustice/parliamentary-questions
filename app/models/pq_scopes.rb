module PqScopes
  def allocated_since(since)
    joins(:action_officers_pqs)
      .where('action_officers_pqs.updated_at >= ?', since)
      .group('pqs.id')
      .order(:uin)
  end

  def not_seen_by_finance
    where(seen_by_finance: false)
  end

  def accepted_in(aos)
    joins(:action_officers_pqs).where(action_officers_pqs: {
      response: 'accepted',
      action_officer_id: aos 
    })
  end

  def ministers_by_progress(ministers, progresses)
    includes(:progress, :minister).
      where(progress_id: progresses, minister_id: ministers).
      group(:minister_id, :progress_id).
      count
  end

  def new_questions
    by_status(Progress.new_questions)
  end

  def in_progress
    by_status(Progress.in_progress_questions)
  end

  def visibles
    by_status(Progress.visible)
  end

  def by_status(status)
    joins(:progress).where(progresses: {name: status})
  end

  def no_response()
    by_status(Progress.NO_RESPONSE)
  end

  def unassigned()
    by_status(Progress.UNASSIGNED)
  end

  def rejected
    by_status(Progress.REJECTED)
  end

  def draft_pending
    by_status(Progress.DRAFT_PENDING)
  end

  def with_pod
    by_status(Progress.WITH_POD)
  end

  def pod_query
    by_status(Progress.POD_QUERY)
  end

  def pod_cleared
    by_status(Progress.POD_CLEARED)
  end

  def with_minister
    by_status(Progress.WITH_MINISTER)
  end

  def ministerial_query
    by_status(Progress.MINISTERIAL_QUERY)
  end

  def minister_cleared
    by_status(Progress.MINISTER_CLEARED)
  end

  def answered
    by_status(Progress.ANSWERED)
  end

  def transferred
    joins(:progress)
      .where('pqs.transferred = true AND progresses.name IN (?)',
             Progress.new_questions)
  end

  def i_will_write_flag
    joins(:progress)
      .where('pqs.i_will_write = true AND progresses.name NOT IN (?)',
             Progress.closed_questions)
  end

  def counts_by_state
    state_counts = joins('join progresses p on p.id = progress_id')
      .select('p.name', 'count(*)')
      .group('p.name')
      .reduce({}) { |acc, r| acc.merge(r.name => r.count) }

    state_counts.merge({
      'view_all'             => Pq.count,
      'view_all_in_progress' => Pq.in_progress.count,
      'transferred_in'       => Pq.transferred.count,
      'iww'                  => Pq.i_will_write_flag.count
    })
  end
end
