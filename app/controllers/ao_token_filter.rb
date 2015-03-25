class AOTokenFilter
  def self.before(controller)
    token_state = validate_token(controller)
    if token_state == :invalid
      LogStuff.error(:token_error) { "type: invalid_token, referrer:#{controller.request.referer}" }
      controller.render :file => "shared/token_invalid.html.slim", :status => :unauthorized
    elsif token_state == :expired
      LogStuff.error(:token_error) { "type: expired_token, referrer:#{controller.request.referer}" }
      controller.render :file => "shared/token_expired.html.slim", :status => :unauthorized
    end
  end

  def self.validate_token(controller)
    result = :invalid
    token_service = TokenService.new

    token = controller.params[:token]
    entity = controller.params[:entity]
    path = controller.request.path

    result = :valid if token_service.valid?(token, path, entity)
    result = :expired if result == :valid && token_service.expired?(token, path, entity)

    return result
  end
end
