ParliamentaryQuestions::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false
  config.assets.enabled = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = true

  config.public_file_server.enabled = true

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Exclude SSL on Healthcheck and ping.json calls
  config.ssl_options = { redirect: { exclude: -> request { request.path.include? '/ping.json' } } }
  config.ssl_options = { redirect: { exclude: -> request { request.path.include? '/healthcheck' } } }

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.action_controller.asset_host = ENV['ASSET_HOST'] if ENV['ASSET_HOST']

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )
  config.assets.precompile += %w(.svg .eot .woff .ttf *.js ^[^_]*.css ^[^_]*.scss)

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = [I18n.default_locale]

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.log_level = :info

  # Custom Logging - uncomment this block if you want to see logstash-style logs written
  # to log/logstash_development.json.
  # A side effect of this is that the normal log/development.log will just contain SQL actions and
  # no details of the controller action or parameters.
  # config.logstasher.enabled = true
  # config.logstasher.log_level = Logger::INFO
  # config.logstasher.logger = ActiveSupport::Logger.new STDOUT

  # This line is optional, it allows you to set a custom value for the @source field of the log event
  # config.logstasher.source = 'logstasher'

  # config.logstasher.suppress_app_log = true
  # End of custom logging block

  # For routes accessed by gecko, we require HTTP basic auth
  # See https://developer.geckoboard.com/#polling-overview
  config.gecko_auth_username = ENV['GECKO_AUTH_USERNAME']

  config.after_initialize do
    sending_host = ENV['SENDING_HOST'] || 'localhost'
    # ActionMailer::Base.default_url_options = { host: sending_host, protocol: 'https' }
    # ActionMailer::Base.default from: Settings.mail_from
    # ActionMailer::Base.default reply_to: Settings.mail_reply_to
    # ActionMailer::Base.smtp_settings = {
    #   address: ENV['SMTP_HOSTNAME'] || 'localhost',
    #   authentication: :login,
    #   domain: sending_host,
    #   enable_starttls_auto: true,
    #   password: ENV['SMTP_PASSWORD'] || '',
    #   port: ENV['SMTP_PORT'] || 587,
    #   user_name: ENV['SMTP_USERNAME'] || ''
    # }
  end
end
