ParliamentaryQuestions::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Rails 6 blocks hosts unless allowed here
  config.hosts << /[a-z0-9]+\.trackparliamentaryquestions\.service\.gov\.uk/

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.log_level = :debug

  # Custom Logging - uncomment this block if you want to see logstash-style logs written
  # to log/logstash_development.json.
  # A side effect of this is that the normal log/development.log will just contain SQL actions and
  # no details of the controller action or parameters.
  # config.logstasher.enabled = true
  # config.logstasher.log_level = Logger::DEBUG
  # config.logstasher.logger = ActiveSupport::Logger.new STDOUT
  #
  # This line is optional, it allows you to set a custom value for the @source field of the log event
  # config.logstasher.source = 'logstasher'
  #
  # config.logstasher.suppress_app_log = true
  # End of custom logging block

  # For routes accessed by gecko, we require HTTP basic auth
  # See https://developer.geckoboard.com/#polling-overview
  config.gecko_auth_username = ENV['GECKO_AUTH_USERNAME']

  config.after_initialize do
    sending_host = ENV['SENDING_HOST'] || 'localhost'
    ActionMailer::Base.delivery_method = :sendmail
    ActionMailer::Base.default from: Settings.mail_from
    ActionMailer::Base.default reply_to: Settings.mail_reply_to
    ActionMailer::Base.default_url_options = { host: sending_host, protocol: 'https' }
    ActionMailer::Base.smtp_settings = {
      address: ENV['SMTP_HOSTNAME'] || 'localhost',
      authentication: :login,
      domain: sending_host,
      enable_starttls_auto: true,
      password: ENV['SMTP_PASSWORD'] || '',
      port: ENV['SMTP_PORT'] || 587,
      user_name: ENV['SMTP_USERNAME'] || ''
    }
  end
end
