module PqCounts
  # Returns a hash with the PQ state as key and count by minister_id as value.
  #
  # It includes only PQs that are in the in progress states (PQState::IN_PROGRESS),
  # and ministers that are active.
  #
  # @returns [Hash[String, Hash]]
  #
  # Example:
  #
  #     {
  #       "no_response" => {
  #         43 => 1,
  #         44 => 10
  #         48 => 2
  #       },
  #       "with_pod" => {
  #         44 => 2
  #       }
  #     }
  def count_in_progress_by_minister
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

  # Returns a hash with the PQ state as key and count by press_desk_id as value.
  #
  # It will filter out PQs that are below the PQState::DRAFT_PENDING state,
  # and press desks that are not active.
  #
  def count_accepted_by_press_desk
    join_press_desks
      .select("pqs.state, ao.press_desk_id, count(distinct pqs.id)")
      .where("state != ?", PQState::UNASSIGNED)
      .where("aopq.response = 'accepted' AND pd.deleted = false")
      .group('state, ao.press_desk_id')
      .reduce({}) { |acc, r|
        h = { r.press_desk_id => r.count }
        acc.merge(r.state => h ) { |_, old_v, new_v| old_v.merge(new_v) }
      }
  end
end