module Presenters
  class DashboardFilters
    attr_reader :filters

    def initialize(filters)
      @filters = filters
    end

    def each(&block)
      @filters.each(&block)
    end

    def self.build(counts, params)
      all_filter = ViewAllFilter.new(counts["view_all"],
                                     "view_all",
                                     "View all",
                                     params)

      transferred_in = TransferedInFilter.new(counts["transferred_in"],
                                              "transferred_in",
                                              "Transferred In",
                                              params)

      new([all_filter] + statuses(counts, params) + [transferred_in])
    end

    def self.build_in_progress(counts, params)
      in_progress = ViewAllInProgressFilter.new(counts["view_all_in_progress"],
                                                "view_all_in_progress",
                                                "View all",
                                                params)

      new([in_progress] + in_progress_statuses(counts, params))
    end

    def self.backlog(counts, params)
      in_progress = ViewAllInProgressFilter.new(counts["view_all_in_progress"],
                                                "view_all_in_progress",
                                                "View all",
                                                params)

      new([in_progress] + in_progress_statuses(counts, params))
    end

    # private_class_method

    def self.statuses(counts, params)
      PqState::NEW.map do |key|
        StatusFilter.new(counts[key], key, PqState.state_label(key), params)
      end
    end

    def self.in_progress_statuses(counts, params)
      PqState::IN_PROGRESS.map do |key|
        InProgressStatusFilter.new(counts[key], key, PqState.state_label(key), params)
      end
    end
  end
end
