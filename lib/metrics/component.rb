module Metrics
  class Component
    def collect!
      #
      # Collects and updates the metrics of the component for the dashboard
      # 
      # Null -> MetricsDashboard::Component
      #
      raise NotImplementedError, 'The #collect! method should be implemented by subclasses'
    end
  end
end