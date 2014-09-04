class WatchlistReportService

  def initialize(tokenService = TokenService.new)
    @tokenService = tokenService
  end


  def send

    path = '/watchlist/dashboard'
    entity = "watchlist-" + DateTime.now.to_s
    end_of_day = DateTime.now.end_of_day.change({:offset => 0})+3
    token = @tokenService.generate_token(path, entity, end_of_day)

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.watchlist"

    template = Hash.new
    template[:name] = 'Watchlist'
    template[:entity] = entity
    template[:email] = 'pqtest@digital.justice.gov.uk'
    template[:token] = token

    watchlist_cc = ''
    watchlist_members = WatchlistMember.where(deleted: false).load
    watchlist_members.each do |member|
      watchlist_cc = watchlist_cc + member.email + ';'
    end
    template[:cc] = watchlist_cc

    Rails.logger.info { "Watchlist  email to #{template[:email]} (name #{template[:name]}) [CCd to #{template[:cc]}]" }
    PqMailer.watchlist_email(template).deliver
    return token

  end

end
