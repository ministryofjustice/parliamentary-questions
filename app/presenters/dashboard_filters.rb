class DashboardFilters
  attr_reader :filters
  def initialize(filters)
    @filters = filters
  end

  def each(&block)
    @filters.each(&block)
  end

  def self.build(counts, params)
    all_filter = ViewAllFilter.new(counts['view_all'],
                                       'view_all',
                                       'View all',
                                       params)

    transferred_in = TransferedInFilter.new(counts['transferred_in'],
                                            'transferred_in',
                                            'Transferred In',
                                            params)

    new([all_filter] + statuses(counts, params) + [transferred_in])
  end

  def self.build_in_progress(counts, params)
    in_progress = ViewAllInProgressFilter.new(counts['view_all_in_progress'],
                                              'view_all_in_progress',
                                              'View all',
                                              params)

    iww = IwwFilter.new(counts['iww'],
                                'iww',
                                'I will write',
                                params)

    new([in_progress] + in_progress_statuses(counts, params) + [iww])
  end

  private_class_method

  def self.statuses(counts, params)
    [
      PQState::UNASSIGNED,
      PQState::NO_RESPONSE,
      PQState::REJECTED,
    ].map do |key|
      StatusFilter.new(counts[key], key, PQState.state_label(key), params)
    end
  end

  def self.in_progress_statuses(counts, params)
    [
      PQState::DRAFT_PENDING,
      PQState::WITH_POD,
      PQState::POD_QUERY,
      PQState::POD_CLEARED,
      PQState::WITH_MINISTER,
      PQState::MINISTERIAL_QUERY,
      PQState::MINISTER_CLEARED,
    ].map do |key|
      InProgressStatusFilter.new(counts[key], key, PQState.state_label(key), params)
    end
  end
end
