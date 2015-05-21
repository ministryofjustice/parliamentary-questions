module Metrics
  class SmokeTests < Component
    attr_reader :run_time

    def collect!
      @run_time     = Time.use_zone('London') { SmokeTestRunner.run_time.in_time_zone } 
      @run_success = SmokeTestRunner.run_success?
    end

    def run_success?
      @run_success
    end
  end
end