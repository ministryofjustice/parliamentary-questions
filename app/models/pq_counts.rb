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
  # @returns [Hash[String, Hash]]
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

  # Returns a hash of PQ counts by state
  #
  # @returns [Hash[String, Fixnum]]
  # 
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