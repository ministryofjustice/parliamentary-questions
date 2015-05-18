class MetricsDashboard
  class SmokeTestInfo < Component
    attr_accessor :run_time, :run_success

    def gather_metrics
      @run_time    = Time.use_zone('London') { SmokeTestRunner.run_time.in_time_zone } 
      @run_success = SmokeTestRunner.run_success?
    end
  end
end