class PQBaseMailer < ActionMailer::Base
  def mail(opts, &block)
    m = super

    class << m
      def deliver
        $statsd.time(StatsHelper::MAIL_TIMING) do
          LogStuff.tag(:mail) do
            begin
              LogStuff.info "Sending mail with subject '#{self[:subject]}'"
              super
              $statsd.increment StatsHelper::MAIL_SUCCESS
            rescue => e
              LogStuff.warn "Problem sending mail with subject '#{self[:subject]}': #{e.inspect}"
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
