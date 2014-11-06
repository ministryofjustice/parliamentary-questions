require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

# This require is necessary to avoid a class error in logstasher.
# This is fixed in HEAD but not currently released in 0.6.1
require 'action_mailer/log_subscriber'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module ParliamentaryQuestions
  class Application < Rails::Application
    # Application Title (Populates <title>)
    config.app_title = 'Parliamentary Questions'
    # Proposition Title (Populates proposition header)
    config.proposition_title = 'PQ Tracker'
    # Current Phase (Sets the current phase and the colour of phase tags)
    # Presumed values: alpha, beta, live
    config.phase = 'beta'
# Product Type (Adds class to body based on service type)
# Presumed values: information, service
    config.product_type = 'service'
# Feedback URL (URL for feedback link in phase banner)
    config.feedback_url = '#'
# Google Analytics ID (Tracking ID for the service)
    config.ga_id = ''

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/scrapers)

    config.encoding = 'utf-8'

    config.active_record.schema_format = :sql

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    #config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.generators do |g|
      g.template_engine :erb
    end

    config.exceptions_app = self.routes


    # Custom Logging
    config.log_level = :info
    config.logstasher.enabled = true
    config.logstasher.suppress_app_log = true
    config.logstasher.log_level = Logger::INFO
    config.logstasher.logger_path = "#{Rails.root}/log/logstash_#{Rails.env}.json"
    # This line is optional, it allows you to set a custom value for the @source field of the log event
    config.logstasher.source = 'logstasher'

    # Statsd
    $statsd = Statsd.new 'localhost', 8125
  end
end
