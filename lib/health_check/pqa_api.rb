module HealthCheck
  class PqaApi < Component
    ERRS_TO_CATCH = 
    [
      Net::ReadTimeout, 
      Errno::ECONNREFUSED, 
      SocketError,
      HTTPClient::FailureResponse
     ]

    def initialize
      @api = PQA::ApiClient.from_settings
      super
    end

    def available?
      res = perform_get(Settings.pq_rest_api.host)
      !!(res.code =~ /^2/)

    rescue *ERRS_TO_CATCH => e
      log_error('Access', e)
      false
    end

    def accessible?
      res = @api.question('1')
      !!(res.code =~ /^2/)

    rescue *ERRS_TO_CATCH => e
      log_error('Authentication', e)
      false
    end

    private

    def log_error(type, e)
      @errors << "PQA API #{type} Error: #{e.message}"
    end

    def perform_get(uri_s)
      uri = URI.parse(uri_s)

      Net::HTTP.start(uri.host, uri.port) do |http|
        req = Net::HTTP::Get.new(uri)
        http.request(req) 
      end
    end
  end
end