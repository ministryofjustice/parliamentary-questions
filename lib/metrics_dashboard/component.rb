class MetricsDashboard
  class Component
    def gather_metrics
      #
      # Updates the metrics of the component for the dashboard
      # 
      # Null -> MetricsDashboard::Component
      #
      raise NotImplementedError, 'The #gather_metrics method should be implemented by subclasses'
    end
  end
end