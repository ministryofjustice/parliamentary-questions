class EarlyBirdReportService
  include Rails.application.routes.url_helpers
  
  def initialize(tokenService = nil, current_time = nil)
    @tokenService = tokenService || TokenService.new
    @current_time = current_time || DateTime.now
  end

  def entity
    "early_bird-" + @current_time.to_s
  end

  def notify_earlybird
    end_of_day = @current_time.end_of_day
    token      = @tokenService.generate_token(early_bird_dashboard_path, entity, end_of_day)
    cc         = EarlyBirdMember.active.pluck(:email).join(';')
    template   = {
      :name   => 'early_bird',
      :entity => entity,
      :email  => 'pqtest@digital.justice.gov.uk',
      :token  => token,
      :cc     => cc
    }

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.earlybird"
    LogStuff.tag(:mailer_earlybird) do
      LogStuff.info { "Early bird  email to #{template[:email]} (name #{template[:name]}) [CCd to #{template[:cc]}]" }
      MailService::Pq.early_bird_email(template)
      #MailService::Pq.watchlist_email(template)
    end
    token
  end
end
