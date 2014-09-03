class WatchlistReportService

  def initialize(tokenService = TokenService.new)
    @tokenService = tokenService
  end


  def send
    result = Hash.new
    watchlist_members = WatchlistMember.where(deleted: false).load
    Rails.logger.info { "Watchlist: Starting to send watchlist allocation emails (total #{watchlist_members.count})" }
    watchlist_members.each_with_index do |member, index|
      token = send_one(index + 1, member)
      result[member.id] = token
    end
    Rails.logger.info { "Watchlist: Completed sending watchlist allocation emails" }
    result
  end


  def send_one(index, member)
    path = '/watchlist/dashboard'
    entity = "watchlist:#{member.id}"
    end_of_day = DateTime.now.end_of_day.change({:offset => 0})
    token = @tokenService.generate_token(path, entity, end_of_day)

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.watchlist"

    template = Hash.new
    template[:name] = member.name
    template[:entity] = entity
    template[:email] = member.email
    template[:token] = token

    Rails.logger.info { "Watchlist: [#{index}] email to #{template[:email]} (name #{template[:name]})" }
    PqMailer.watchlist_email(template).deliver
    return token
  end
end
