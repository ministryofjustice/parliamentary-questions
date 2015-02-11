class WatchlistReportService
  include Rails.application.routes.url_helpers
  def initialize(tokenService = TokenService.new)
    @tokenService = tokenService
    @@timestamp = DateTime.now.to_s
  end

  def timestamp
    @@timestamp
  end

  def entity
    "watchlist-" + @@timestamp
  end

  def notify_watchlist
    end_of_day = DateTime.now.end_of_day
    token      = @tokenService.generate_token(watchlist_dashboard_path, entity, end_of_day)
    cc         = WatchlistMember.where(deleted: false).map(&:email).join(' ;')
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
      PqMailer.watchlist_email(template).deliver
    end
    token
  end
end
