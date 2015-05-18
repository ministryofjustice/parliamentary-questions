class MetricsDashboard
  COMPONENTS = 
  {
    key_metric:      KeyMetric,
    health:          Health,
    app_info:        AppInfo,
    smoke_test_info: SmokeTestInfo,
    mail_info:       MailInfo,
    pqa_import_info: PqaImportInfo
  }

  attr_reader :components,
              :gecko

  def initialize
    @components = component_factory
    @gecko      = GeckoCollection.new
  end

  def update
    gather_metrics
    gecko.update(components)
    self
  end

  private

  def gather_metrics    
    @components.to_h.values.each(&:gather_metrics)    
  end

  def component_factory
    OpenStruct.new(
      COMPONENTS.map { |name, component| [ name , component.new ] }.to_h
    )
  end
end
