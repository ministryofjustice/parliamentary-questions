class AOTokenFilter
  def self.before(controller)
    if !has_access(controller)
      controller.update_page_title "Unauthorised (401)"
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
