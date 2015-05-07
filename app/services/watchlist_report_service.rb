class WatchlistReportService
  include Rails.application.routes.url_helpers
  
  def initialize(tokenService = nil, current_time = nil)
    @tokenService = tokenService || TokenService.new
    @current_time = current_time || DateTime.now
  end

  def entity
    "watchlist-" + @current_time.to_s
  end

  def notify_watchlist
    end_of_day = @current_time.end_of_day
    token      = @tokenService.generate_token(watchlist_dashboard_path, entity, end_of_day)
    cc         = WatchlistMember.active.pluck(:email).join(' ;')
    template   = {
      :name   => 'Watchlist',
      :entity => entity,
      :email  => 'pqtest@digital.justice.gov.uk',
      :token  => token,
      :cc     => cc
    }

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.watchlist"
    LogStuff.tag(:mailer_watchlist) do
      LogStuff.info { "Watchlist  email to #{template[:email]} (name #{template[:name]}) [CCd to #{template[:cc]}]" }
      MailService::Pq.watchlist_email(template)
    end
    token
  end
end
