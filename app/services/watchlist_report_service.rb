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
    recipients = WatchlistMember.active.pluck(:email) << 'pqtest@digital.justice.gov.uk'

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.watchlist"
    recipients.each do |recipient|
      LogStuff.tag(:mailer_watchlist) do
        LogStuff.info { "Watchlist  email to pqtest@digital.justice.gov.uk (name Watchlist) [CCd to #{recipients.join(';')}]" }
        NotifyPqMailer.watchlist_email(email: recipient, token: token, entity: entity).deliver_later
      end
    end
    token
  end
end
