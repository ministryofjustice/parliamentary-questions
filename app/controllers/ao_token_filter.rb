require "ostruct"

class AoTokenFilter
  def self.before(controller)
    token_state = validate_token(controller)
    log_and_redirect(controller, token_state) unless token_state == :valid
  end

  # private

  def self.validate_token(controller)
    result        = :invalid
    token_service = TokenService.new
    token         = controller.params[:token]
    entity        = controller.params[:entity]
    path          = controller.request.path
    result        = :valid if token_service.valid?(token, path, entity)
    result        = :expired if result == :valid && token_service.expired?(token, path, entity)

    result
  end

  def self.log_and_redirect(controller, token_state)
    params         = ::OpenStruct.new
    params.uri     = controller.request.env["REQUEST_URI"]
    params.referer = controller.request.referer
    params.uin     = extract_uin(controller)
    params.user    = extract_user_name(controller)

    log_error(token_state, params)

    controller.update_page_title "Unauthorised (401)"
    controller.render "shared/token_#{token_state}", status: :unauthorized
  end

  def self.log_error(token_state, params)
    LogStuff.error(
      :token_error,
      type: "#{token_state}_token",
      uri: params.uri,
      referer: params.referer,
      uin: params.uin,
      user: params.user,
    ) { "Access Token Error - #{token_state.to_s.humanize} Token" }
  end

  def self.extract_uin(controller)
    request_path = controller.request.path
    if request_path =~ %r{^/assignment/}
      controller.request.path.split("/").last
    end
  end

  def self.extract_user_name(controller)
    if controller.current_user.nil?
      "User not logged in"
    else
      controller.current_user.name
    end
  end
end
