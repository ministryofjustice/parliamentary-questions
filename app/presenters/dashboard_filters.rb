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
    {
      Progress.UNASSIGNED  => 'Unassigned',
      Progress.NO_RESPONSE => 'No response',
      Progress.REJECTED    => 'Rejected',
    }.map do |key, label|
      StatusFilter.new(counts[key], key, label, params)
    end
  end

  def self.in_progress_statuses(counts, params)
    {
      Progress.DRAFT_PENDING     => 'Draft Pending',
      Progress.WITH_POD          => 'With POD',
      Progress.POD_QUERY         => 'POD Query',
      Progress.POD_CLEARED       => 'POD Cleared',
      Progress.WITH_MINISTER     => 'With Minister',
      Progress.MINISTERIAL_QUERY => 'Ministerial Query',
      Progress.MINISTER_CLEARED  => 'Minister Cleared'
    }.map do |key, label|
      InProgressStatusFilter.new(counts[key], key, label, params)
    end
  end
end
