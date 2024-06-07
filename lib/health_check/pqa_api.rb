module HealthCheck
  class PQAApi < Component
    TIMESTAMP_FILE = Rails.root.join("tmp/pqa_api_healthcheck_timestamp").to_s.freeze

    ERRS_TO_CATCH =
      [
        Net::ReadTimeout,
        Errno::ECONNREFUSED,
        SocketError,
        HTTPClient::FailureResponse,
      ].freeze

    def self.time_to_run?
      interval = minimum_interval_in_seconds
      last_run = time_last_run
      Time.zone.now.to_i > interval + last_run
    end

    def initialize
      @api = PQA::ApiClient.from_settings
      super
    end

    def record_result
      tmpdir = Rails.root.join("tmp").to_s
      Dir.mkdir(tmpdir) unless Dir.exist?(tmpdir)
      status = @errors.any? ? "FAIL" : "OK"

      File.open(TIMESTAMP_FILE, "w") do |fp|
        t = Time.zone.now.utc
        fp.puts "#{t.to_i}::#{status}::#{@errors.to_json}"
      end
    end

    def available?
      res = perform_get(Settings.pq_rest_api.host)
      !!(res.code =~ /^2/)
    rescue *ERRS_TO_CATCH => e
      log_error("Access", e)
      false
    rescue StandardError => e
      log_unknown_error(e)
      false
    end

    def accessible?
      res = @api.question("1")
      !!(res.code =~ /^2/)
    rescue *ERRS_TO_CATCH => e
      log_error("Authentication", e)
      false
    rescue StandardError => e
      log_unknown_error(e)
      false
    end

    def self.minimum_interval_in_seconds
      Settings.healthcheck_pqa_api_interval * 60
    end

    private_class_method :minimum_interval_in_seconds

    def self.time_last_run
      if File.exist?(TIMESTAMP_FILE)
        File.open(TIMESTAMP_FILE, "r") do |fp|
          interval, = fp.gets.chomp.split("::")
          interval.to_i
        end
      else
        0
      end
    end

    private_class_method :time_last_run

  private

    def log_error(type, error)
      @errors << "PQA API #{type} Error: #{error.message}"
    end

    def perform_get(uri_s)
      Net::HTTP.get_response(URI.parse(uri_s))
    end
  end
end
