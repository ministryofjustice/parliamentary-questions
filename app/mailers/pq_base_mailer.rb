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

  protected

  def prefix(subject)
    "[#{app_env}][#{app_version}] #{subject}"
  end

  def app_version
    ENV.fetch('APPVERSION', 'version-unknown')
  end

  def app_env
    case ENV['SENDING_HOST']
    when 'trackparliamentaryquestions.service.gov.uk'
      'production'
    when 'staging.pq.dsd.io'
      'staging'
    when 'dev.pq.dsd.io'
      'dev'
    else
      'env-unknown'
    end
  end
end
