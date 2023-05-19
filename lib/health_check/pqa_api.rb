module HealthCheck
  class PqaApi < Component
    TIMESTAMP_FILE = "#{Rails.root}/tmp/pqa_api_healthcheck_timestamp"

    ERRS_TO_CATCH = [Net::ReadTimeout, Errno::ECONNREFUSED, SocketError, HTTPClient::FailureResponse]

    def self.time_to_run?
      interval = minimum_interval_in_seconds
      last_run = time_last_run
      Time.now.to_i > interval + last_run
    end

    def initialize
      @api = PQA::ApiClient.from_settings
      super
    end

    def record_result
      tmpdir = "#{Rails.root}/tmp"
      FileUtils.mkdir_p(tmpdir)
      status = @errors.any? ? 'FAIL' : 'OK'

      File.open(TIMESTAMP_FILE, 'w') do |fp|
        t = Time.now.utc
        fp.puts "#{t.to_i}::#{status}::#{@errors.to_json}"
      end
    end

    def available?
      res = perform_get(Settings.pq_rest_api.host)
      !!(res.code =~ /^2/)
    rescue *ERRS_TO_CATCH => e
      log_error('Access', e)
      false
    rescue => e
      log_unknown_error(e)
      false
    end

    def accessible?
      res = @api.question('1')
      !!(res.code =~ /^2/)
    rescue *ERRS_TO_CATCH => e
      log_error('Authentication', e)
      false
    rescue => e
      log_unknown_error(e)
      false
    end

    private

    def self.minimum_interval_in_seconds
      Settings.healthcheck_pqa_api_interval * 60
    end

    def self.time_last_run
      if File.exist?(TIMESTAMP_FILE)
        File.open(TIMESTAMP_FILE, 'r') do |fp|
          interval, status, error_messages_as_json = fp.gets.chomp.split('::')
          interval = interval.to_i
        end
      else
        0
      end
    end

    def log_error(type, e)
      @errors << "PQA API #{type} Error: #{e.message}"
    end

    def perform_get(uri_s)
      Net::HTTP.get_response(URI.parse(uri_s))
    end
  end
end
