module PqScopes
  def allocated_since(since)
    joins(:action_officers_pqs)
      .where("action_officers_pqs.updated_at >= ?", since)
      .group("pqs.id")
      .order(:uin)
  end

  def answered
    by_status(PqState::ANSWERED)
  end

  def backlog
    where("date_for_answer < CURRENT_DATE and state NOT IN (?)", PqState::CLOSED)
  end

  def by_status(states)
    where(state: states)
  end

  def draft_pending
    by_status(PqState::DRAFT_PENDING)
  end

  def filter_for_report(state, minister_id, press_desk_id)
    q = order(:internal_deadline)
    q = join_press_desks.where("pd.id = ?", press_desk_id).distinct("pqs.uin") if press_desk_id.present?
    q = q.where(state:) if state.present?
    q = q.where(minister_id:) if minister_id.present?
    q
  end

  def i_will_write_flag
    where("i_will_write = true AND state NOT IN (?)", PqState::CLOSED)
  end

  def imported_since_last_weekday
    end_of_last_weekday = Time.zone.today.last_weekday.end_of_day
    end_of_today = Time.zone.today.end_of_day
    where("created_at BETWEEN ? AND ?", end_of_last_weekday, end_of_today)
  end

  def in_progress
    where("date_for_answer >= CURRENT_DATE and state IN (?)", PqState::IN_PROGRESS)
  end

  def join_press_desks
    joins("JOIN action_officers_pqs aopq ON aopq.pq_id = pqs.id")
      .joins("JOIN action_officers ao ON ao.id = aopq.action_officer_id")
      .joins("JOIN press_desks pd ON pd.id = ao.press_desk_id")
      .where("aopq.response = 'accepted' AND pd.deleted = false")
  end

  def minister_cleared
    by_status(PqState::MINISTER_CLEARED)
  end

  def ministerial_query
    by_status(PqState::MINISTERIAL_QUERY)
  end

  def new_questions
    by_status(PqState::NEW)
  end

  def no_response
    by_status(PqState::NO_RESPONSE)
  end

  def not_tx
    where("transfer_out_ogd_id is null AND question_type != 'Follow-up IWW'")
  end

  def on_time
    not_tx.where("answer_submitted <= (date_for_answer + 1)")
  end

  def pod_cleared
    by_status(PqState::POD_CLEARED)
  end

  def pod_query
    by_status(PqState::POD_QUERY)
  end

  def rejected
    by_status(PqState::REJECTED)
  end

  # dashboard sorting order:
  #
  # - first PQs due today, ordered by state-weight in descending order
  # - then PQs due tomorrow, ordered by state-weight in descending order
  # - then PQs due day after tomorrow, ordered by state-weight in descending order, etc
  # - then PQs due yesterday, ordered by state-weight in descending order
  # - then PQs due the day before yesterday, ordered by state-weight in descending order
  #
  # We use Time.zone.today.strftime('%Y-%m-%d') here instead of the postgres function CURRENT_DATE in order to be able to get
  # consistent results using Timecop in the tests
  #

  def sorted_for_dashboard
    current_date = "'#{Time.zone.today.strftime('%Y-%m-%d')}'"
    order(Arel.sql("date_for_answer >= #{current_date} DESC"))
      .order(Arel.sql("ABS(DATE_PART('day', date_for_answer::timestamp - #{current_date}::timestamp)) ASC"))
      .order(Arel.sql("state_weight DESC"))
      .order(Arel.sql("updated_at ASC"))
      .order(Arel.sql("id"))
  end

  def transferred
    where(state: PqState::NEW, transferred: true)
  end

  def uin(uin_to_search)
    find_by("uin = ?", uin_to_search)
  end

  def unassigned
    by_status(PqState::UNASSIGNED)
  end

  def visibles
    by_status(PqState::VISIBLE)
  end

  def with_minister
    by_status(PqState::WITH_MINISTER)
  end

  def with_pod
    by_status(PqState::WITH_POD)
  end
end
