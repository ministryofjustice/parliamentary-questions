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

  def in_progress_pqs_by_minister
    select("minister_id, state, count(*)")
      .joins(:minister)
      .where(state: PQState::IN_PROGRESS)
      .where('ministers.deleted = false')
      .group(:state, :minister_id)
      .reduce({}) { |acc, r|
        h = { r.minister_id => r.count }
          acc.merge(r.state => h ) { |_, old_v, new_v| old_v.merge(new_v) }
      }
  end

  def accepted_by_press_desk
    select("pqs.state, ao.press_desk_id, count(*)")
      .joins('JOIN action_officers_pqs aopq ON aopq.pq_id = pqs.id')
      .joins('JOIN action_officers ao ON ao.id = aopq.action_officer_id')
      .joins('JOIN press_desks pd ON pd.id = ao.press_desk_id')
      .where("state != ?", PQState::UNASSIGNED)
      .where("aopq.response = 'accepted' AND pd.deleted = false")
      .group('state, ao.press_desk_id')
      .reduce({}) { |acc, r|
        h = { r.press_desk_id => r.count }
        acc.merge(r.state => h ) { |_, old_v, new_v| old_v.merge(new_v) }
      }
  end

  def accepted_in(aos)
    joins(:action_officers_pqs).where(action_officers_pqs: {
      response: 'accepted',
      action_officer_id: aos 
    })
  end

  def new_questions
    by_status(PQState::NEW)
  end

  def in_progress
    by_status(PQState::IN_PROGRESS)
  end

  def visibles
    by_status(PQState::VISIBLE)
  end

  def by_status(states)
    where(state: states)
  end

  def no_response()
    by_status(PQState::NO_RESPONSE)
  end

  def unassigned()
    by_status(PQState::UNASSIGNED)
  end

  def rejected
    by_status(PQState::REJECTED)
  end

  def draft_pending
    by_status(PQState::DRAFT_PENDING)
  end

  def with_pod
    by_status(PQState::WITH_POD)
  end

  def pod_query
    by_status(PQState::POD_QUERY)
  end

  def pod_cleared
    by_status(PQState::POD_CLEARED)
  end

  def with_minister
    by_status(PQState::WITH_MINISTER)
  end

  def ministerial_query
    by_status(PQState::MINISTERIAL_QUERY)
  end

  def minister_cleared
    by_status(PQState::MINISTER_CLEARED)
  end

  def answered
    by_status(PQState::ANSWERED)
  end

  def transferred
    where(state: PQState::NEW, transferred: true)
  end

  def i_will_write_flag
    where('i_will_write = true AND state NOT IN (?)', PQState::CLOSED)
  end

  #def sorted_for_dashboard
  #  order("date_for_answer > CURRENT_DATE ASC")
  #    .order("DATE_PART('day', date_for_answer::timestamp - CURRENT_DATE::timestamp) ASC")
  #    .order('state_weight DESC')
  #    .order('updated_at ASC')
  #end

  def counts_by_state
    state_counts = select('state', 'count(*)')
                     .group('state')
                     .reduce({}) { |acc, r| acc.merge(r.state => r.count) }

    state_counts.merge({
      'view_all'             => Pq.count,
      'view_all_in_progress' => Pq.in_progress.count,
      'transferred_in'       => Pq.transferred.count,
      'iww'                  => Pq.i_will_write_flag.count
    })
  end
end
