# This mailer provides basic metrics and log generation and should be used for all mail creation

class PQBaseMailer < ActionMailer::Base

  def mail(opts, &block)
    m = super

    class << m
      attr_accessor :logger

      # Re-open the message object and wrap the deliver method since that is when the actual error is thrown.
      def deliver( )
        $statsd.time(StatsHelper::MAIL_TIMING) do 
          begin
            Rails.logger.info "Sending mail with subject '#{self[:subject]}'"
            super
            $statsd.increment StatsHelper::MAIL_SUCCESS
          rescue => e
            logger.warn "Problem sending mail with subject '#{self[:subject]}': #{e.inspect}"
            $statsd.increment StatsHelper::MAIL_FAILURE
            raise e
          end
        end
      end
    end

    m.logger = logger
    m
  end
end

