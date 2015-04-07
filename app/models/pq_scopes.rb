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

  def filter_for_report(state, minister_id, press_desk_id)
    q = order(:internal_deadline)
    q = join_press_desks.where('pd.id = ?', press_desk_id).distinct('pqs.uin') if press_desk_id.present?
    q = q.where(state: state) if state.present?
    q = q.where(minister_id: minister_id) if minister_id.present?
    q
  end

  def join_press_desks
    joins('JOIN action_officers_pqs aopq ON aopq.pq_id = pqs.id')
      .joins('JOIN action_officers ao ON ao.id = aopq.action_officer_id')
      .joins('JOIN press_desks pd ON pd.id = ao.press_desk_id')
      .where("aopq.response = 'accepted' AND pd.deleted = false")
  end

  def sorted_for_dashboard
    order("date_for_answer > CURRENT_DATE DESC")
      .order("ABS(DATE_PART('day', date_for_answer::timestamp - CURRENT_DATE::timestamp)) ASC")
      .order('state_weight DESC')
      .order('updated_at ASC')
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
end
