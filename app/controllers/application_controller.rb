class ApplicationController < ActionController::Base
  before_action :set_am_host
  before_action :set_page_title
  before_action :set_paper_trail_whodunnit

  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  if Rails.env.production? || ENV["TRAP_ERRORS_IN_TEST"] == "1"
    rescue_from StandardError do |exception|
      if exception.is_a?(ActiveRecord::RecordNotFound)
        page_not_found(exception)
      else
        server_error(exception)
      end
    end
  end

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

  def page_not_found(exception = nil)
    update_page_title "Not found (404)"
    show_error_page_and_increment_statsd(404, exception)
  end

  def unauthorized
    update_page_title "Unauthorized (401)"
    show_error_page_and_increment_statsd(401)
  end

  def server_error(exception)
    update_page_title "Server Error (500)"
    show_error_page_and_increment_statsd(500, exception)
  end

  def update_page_title(prefix, suffix = "Parliamentary Questions - Ministry of Justice")
    @page_title = "#{prefix} - #{suffix}"
  end

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path and return unless current_user.admin?
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

  def show_error_page_and_increment_statsd(err_number, exception = nil)
    $statsd.increment("#{StatsHelper::PAGES_ERRORS}.#{err_number}") # rubocop:disable Style/GlobalVars
    respond_to do |format|
      format.html { render file: "public/#{err_number}.html", status: err_number, layout: nil }
      format.all  { head :no_content, status: err_number }
    end
    backtrace = exception.nil? ? nil : exception.backtrace
    message = exception.nil? ? nil : exception.message
    LogStuff.error(:error_page) { "status: #{err_number}, referrer:#{request.referer}, url:#{request_url}, message:#{message}, backtrace:#{backtrace}" }
  end
end
