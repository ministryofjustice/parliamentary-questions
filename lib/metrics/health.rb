module Metrics
  class Health < Component
    attr_reader :db_status,
                :sendgrid_status,
                :pqa_api_status,
                :pqa_api_error_message

    def collect!
      @db_status       = current_db_status
      @sendgrid_status = current_sendgrid_status
      @pqa_api_status  = current_pqa_api_status
    end

    private

    def current_db_status
      checker = HealthCheck::Database.new

      checker.accessible? && checker.available?
    end

    def current_sendgrid_status
      checker = HealthCheck::SendGrid.new

      checker.accessible? && checker.available?
    end

    def current_pqa_api_status
      pqa_check = PqaFile.default

      if !pqa_check
        msg("Unable to open #{PqaFile::DEFAULT_PATH}")
      elsif pqa_check.stale?
        msg("PQA API not checked since #{pqa_check.last_run_time}")
      elsif pqa_check.failed_status?
        msg("PQA API check failed with status: #{pqa_check.status}")
      else
        return true
      end

      false
    end

    def msg(string)
      @pqa_api_error_message = string
    end

    class PqaFile
      DEFAULT_PATH = HealthCheck::PqaApi::TIMESTAMP_FILE

      attr_reader :last_run_time, :status

      def self.default
        File.exists?(DEFAULT_PATH) ? new(DEFAULT_PATH) : nil
      end

      def stale?
        last_run_time + (Settings.healthcheck_pqa_api_interval + 5).minutes < Time.now.utc
      end

      def failed_status?
        status != 'OK'
      end

      private

      def initialize(path)
        timestamp, status, = File.read(path).split('::')

        @last_run_time = Time.at(timestamp.to_i).utc
        @status        = status
      end
    end
  end
end
