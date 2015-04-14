class PQBaseMailer < ActionMailer::Base
  def mail(opts, &block)
    m = super

    class << m
      def deliver
        $statsd.time(StatsHelper::MAIL_TIMING) do
          LogStuff.tag(:mail) do
            begin
              super
              LogStuff.info(:mail_successful) { "Successfully sent mail with subject '#{self[:subject]}'" }
              $statsd.increment StatsHelper::MAIL_SUCCESS
            rescue => e
              LogStuff.error(:mail_unsuccessful) { "Problem sending mail with subject '#{self[:subject]}': #{e.inspect}" }
              $statsd.increment StatsHelper::MAIL_FAILURE
              raise e
            end
          end
        end
      end
    end

    m
  end
end
