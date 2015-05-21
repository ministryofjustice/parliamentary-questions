class MetricsDashboard
  attr_reader :metrics,
              :gecko

  def initialize
    @metrics = metric_factory
    @gecko   = GeckoCollection.new
  end

  def update
    collect_metrics!
    gecko.update(metrics)
    self
  end

  private

  def collect_metrics!  
    @metrics.to_h.values.each(&:collect!)    
  end

  def metric_factory
    OpenStruct.new({
      key_metric:  Metrics::KeyMetric.new,
      health:      Metrics::Health.new,
      application: Metrics::Application.new,
      smoke_tests: Metrics::SmokeTests.new,
      mail:        Metrics::Mail.new,
      pqa_import:  Metrics::PqaImport.new
    })
  end
end
