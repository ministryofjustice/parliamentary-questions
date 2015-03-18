class ApplicationController < ActionController::Base
  before_action :set_am_host
  before_action :set_page_title

  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from StandardError do |exception|
    case exception.class
    when ActiveRecord::RecordNotFound, ActionController::RoutingError
      page_not_found
    else
      server_error
    end
  end

  def set_am_host
    request = self.request
    opts = ::ActionMailer::Base.default_url_options
    opts[:host] = request.host
    protocol = /(.*):\/\//.match(request.protocol)[1] if request.protocol.ends_with?("://")
    opts[:protocol] = protocol
  end

  def after_invite_path_for(resource)
    users_path
  end

  def page_not_found
    @page_title = 'Error Page 404'
    show_error_page_and_increment_statsd(404)
  end

  def unauthorized
    @page_title = 'Error Page 401'
    show_error_page_and_increment_statsd(401)
  end

  def server_error
    @page_title = 'Error Page 500'
    show_error_page_and_increment_statsd(500)
  end

protected

  def set_page_title
    @page_title = 'MOJ Parliamentary Questions'
  end

  def request_url
    "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
  end



  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:invite).concat [:name, :roles]
    devise_parameter_sanitizer.for(:accept_invitation).concat [:name, :roles, :invitation_token, :password, :password_confirmation]
    devise_parameter_sanitizer.for(:accept_invitation) do |u|
      u.permit(:name, :roles, :password, :password_confirmation, :invitation_token)
    end
  end

  def show_error_page_and_increment_statsd(err_number)
    $statsd.increment("#{StatsHelper::PAGES_ERRORS}.#{err_number}")
    respond_to do |format|
      format.html { render file: "public/#{err_number}", status: err_number }
      format.all  { render nothing: true, status: err_number }
    end
    LogStuff.info(:error_page) { "status: #{err_number}, referrer:#{request.referer}, url:#{request_url}" }

  end
end

