# This mailer provides basic metrics and log generation and should be used for all mail creation

class PqBaseMailer < ActionMailer::Base

  def mail(opts, &block)
    m = super

    class << m
      attr_accessor :logger

      # Re-open the message object and wrap the deliver method since that is when the actual error is thrown.
      def deliver( )
        $statsd.time(StatsHelper::MAIL_TIMING) do 
          begin
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

