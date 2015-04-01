class AOTokenFilter
  def self.before(controller)
    if !has_access(controller)
      controller.update_page_title "Unauthorised (401)"
      controller.render :file => "shared/token_expired.html.slim", :status => :unauthorized
    end
  end

  def self.has_access(controller)
    token_service = TokenService.new

    token = controller.params[:token]
    entity = controller.params[:entity]
    path = controller.request.path

    is_valid = token_service.is_valid(token, path, entity)

    suffix = 'other'
    if path.include? 'assignment'
      suffix = 'commission'
    end
    if path.include? 'watchlist'
      suffix = 'watchlist'
    end

    if is_valid
      $statsd.increment "#{StatsHelper::TOKENS_VALID}.#{suffix}"
    else
      $statsd.increment "#{StatsHelper::TOKENS_INVALID}.#{suffix}"
    end

    return is_valid
  end
end
