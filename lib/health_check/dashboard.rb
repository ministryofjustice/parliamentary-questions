module HealthCheck
  class Dashboard < Component
    include Capybara::DSL

    def initialize
      @errors = []
    end

    def available?
      res = perform_get(dashboard_path)
      !!(res.code =~ /^2/ || /^3/)
    end

    def accessible?
      #post to signin
      #check 200 on dashboard
      res = perform_get(dashboard_path)
      !!(res.code =~ 200)
    end

    def error_messages
      @errors
    end
  end
end