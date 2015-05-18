class MetricsDashboard
  class KeyMetric < Component
    attr_reader :alert
    
    def initialize
      @alert = false
    end

    def gather_metrics
      @alert = PqStatistics.key_metric_alert?
    end
  end
end