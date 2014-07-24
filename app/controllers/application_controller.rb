class ApplicationController < ActionController::Base
  before_action :set_am_host

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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

end
