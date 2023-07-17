module Metrics
  class KeyMetric < Component
    attr_reader :alert

    def initialize # rubocop:disable Lint/MissingSuper
      @alert = false
    end

    def collect!
      @alert = PqStatistics.key_metric_alert?
    end
  end
end
