ParliamentaryQuestions::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

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

  # Custom Logging - unocmment this block if you want to see logstash-style logs written
  # to log/logstash_development.json.
  # A side effect of this is that the normal log/development.log will just contain SQL actions and
  # no details of the controller action or parameters.
      # config.logstasher.enabled = true
      # config.logstasher.suppress_app_log = true
      # config.logstasher.log_level = Logger::INFO
      # config.logstasher.logger_path = "#{Rails.root}/log/logstash_#{Rails.env}.json"
      # config.logstasher.source = 'logstasher'
  # End of custom logging block

  # For routes accessed by gecko, we require HTTP basic auth
  # See https://developer.geckoboard.com/#polling-overview
  config.gecko_auth_username = ENV['GECKO_AUTH_USERNAME']

  config.after_initialize do
    sending_host = ENV['SENDING_HOST'] || 'localhost'
    ActionMailer::Base.delivery_method = :sendmail
    ActionMailer::Base.default :from => Settings.mail_from
    ActionMailer::Base.default :reply_to => Settings.mail_reply_to
    ActionMailer::Base.default_url_options = { host: sending_host, protocol: 'http', port: '3000'}
    ActionMailer::Base.smtp_settings = {
        address: ENV['SMTP_HOSTNAME'] || 'localhost',
        port: ENV['SMTP_PORT'] || 587,
        domain: sending_host,
        user_name: ENV['SMTP_USERNAME'] || '',
        password: ENV['SMTP_PASSWORD'] || '',
        authentication: :login,
        enable_starttls_auto: true
    }
  end
end
