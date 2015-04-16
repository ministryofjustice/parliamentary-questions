module HealthCheck
  class PqRestApi < Component
    def initialize
      @errors = []
      @api = PQA::ApiClient.from_settings
    end

    def available?
      res = perform_get(Settings.pq_rest_api.host)
      !!(res.code =~ /^2/)
    end

    def accessible?
      res = @api.question('1')
      !!(res.code =~ /^2/)
    end

    def error_messages
      @errors
    end
  end
end