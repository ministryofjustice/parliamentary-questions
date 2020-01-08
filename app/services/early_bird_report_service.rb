class EarlyBirdReportService
  include Rails.application.routes.url_helpers

  def initialize(token_service = nil, current_time = nil)
    @token_service = token_service || TokenService.new
    @current_time = current_time || DateTime.now.utc
  end

  def entity
    'early_bird-' + @current_time.to_s
  end

  def notify_early_bird
    end_of_day = @current_time.end_of_day
    token      = @token_service.generate_token(early_bird_dashboard_path, entity, end_of_day)
    recipients = EarlyBirdMember.active.pluck(:email) << 'pqtest@digital.justice.gov.uk'

    recipients.each do |recipient|
      $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.earlybird"
      LogStuff.tag(:mailer_early_bird) do
        LogStuff.info { "Early bird  email to pqtest@digital.justice.gov.uk} (name early_bird) [CCd to #{recipients.join(';')}]" }
        NotifyPqMailer.early_bird_email(email: recipient, token: token, entity: entity).deliver_now
      end
    end
    token
  end
end
