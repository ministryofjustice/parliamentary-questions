class WatchlistReportService
  include Rails.application.routes.url_helpers

  def initialize(token_service = nil, current_time = nil)
    @token_service = token_service || TokenService.new
    @current_time = current_time || DateTime.now.utc
  end

  def entity
    'watchlist-' + @current_time.to_s
  end

  def notify_watchlist
    end_of_day = @current_time.end_of_day
    token      = @token_service.generate_token(watchlist_dashboard_path, entity, end_of_day)
    recipients = WatchlistMember.active.pluck(:email)
    template   = {
      name: 'Watchlist',
      entity: entity,
      email: 'pqtest@digital.justice.gov.uk',
      token: token,
      recipients: recipients
    }

      recipients.each do |recipient|

      $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.watchlist"
      LogStuff.tag(:mailer_watchlist) do
        LogStuff.info { "Watchlist  email to #{template[:email]} (name #{template[:name]}) [CCd to #{template[:recipients]}]" }
        NotifyPqMailer.watchlist_email(email: recipient, token: token, entity: entity).deliver_now
      end
    end
    token
  end
end
