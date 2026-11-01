class ApplicationController < ActionController::Base
  before_action :set_am_host
  before_action :set_page_title
  before_action :set_paper_trail_whodunnit

  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_am_host
    request = self.request
    opts = ::ActionMailer::Base.default_url_options
    opts[:host] = request.host
    protocol = %r{(.*)://}.match(request.protocol)[1] if request.protocol.ends_with?("://")
    opts[:protocol] = protocol
  end

  # def after_invite_path_for(resource)
  def after_invite_path_for(_resource)
    users_path
  end

  def update_page_title(prefix, suffix = "Parliamentary Questions - Ministry of Justice")
    @page_title = "#{prefix} - #{suffix}"
  end

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path and return unless current_user.admin?
  end

  # Carries the marker Users::OauthHandoffController reads to suppress its
  # auto-submit. Without it the handoff would submit itself immediately, and
  # because the Entra session outlives the PQ one the user would be signed
  # straight back in — making "Sign out" a lie.
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path(signed_out: 1)
  end

protected

  def set_page_title
    @page_title = "Parliamentary Questions - Ministry of Justice"
  end

  def request_url
    "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: %i[param1 param2 param3])
    devise_parameter_sanitizer.permit(:invite, keys: %i[name roles])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[name roles invitation_token password password_confirmation])
  end
end
