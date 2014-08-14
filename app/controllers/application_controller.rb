class ApplicationController < ActionController::Base
  before_action :set_am_host

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Set the host/port that ActionMailer uses to generate urls to the 'Host'
  # header from the request. AKA what should be a sane default. Stupid Rails.
  def set_am_host
    request = self.request
    opts = ::ActionMailer::Base.default_url_options
    opts[:host] = request.host
    opts[:port] = request.port unless [80, 443].include?(request.port)
    protocol = /(.*):\/\//.match(request.protocol)[1] if request.protocol.ends_with?("://")
    opts[:protocol] = protocol
  end

  def after_invite_path_for(resource)
    users_path
  end

  def page_not_found
    $statsd.increment("#{StatsHelper::PAGES_ERRORS}.404")
    respond_to do |format|
      format.html { render file: 'public/404.html', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

  def unauthorized
    $statsd.increment("#{StatsHelper::PAGES_ERRORS}.401")
    respond_to do |format|
      format.html { render file: 'public/401.html', status: 401 }
      format.all  { render nothing: true, status: 401 }
    end
  end

  def server_error
    $statsd.increment("#{StatsHelper::PAGES_ERRORS}.500")
    respond_to do |format|
      format.html { render file: 'public/500.html', status: 500 }
      format.all  { render nothing: true, status: 500}
    end
  end
  protected

  def configure_permitted_parameters
    # Only add some parameters
    devise_parameter_sanitizer.for(:invite).concat [:name, :roles]
    # Only add some parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:name, :roles, :invitation_token, :password, :password_confirmation]
    # Override accepted parameters
    devise_parameter_sanitizer.for(:accept_invitation) do |u|
      u.permit(:name, :roles, :password, :password_confirmation, :invitation_token)
    end
  end

end
