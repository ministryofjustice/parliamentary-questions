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

  def imported_since_last_weekday
    end_of_last_weekday = Time.zone.today.last_weekday.end_of_day
    end_of_today = Time.zone.today.end_of_day
    where("created_at BETWEEN ? AND ?", end_of_last_weekday, end_of_today)
  end

  def in_progress
    where("date_for_answer >= CURRENT_DATE and state IN (?)", PqState::IN_PROGRESS)
  end

  def minister_cleared
    by_status(PqState::MINISTER_CLEARED)
  end

  def new_questions
    by_status(PqState::NEW)
  end

  def no_response
    by_status(PqState::NO_RESPONSE)
  end

  def pod_cleared
    by_status(PqState::POD_CLEARED)
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
