require_relative "boot"
$LOAD_PATH << File.expand_path("../lib", __dir__)

require "pq_state"
require "pq_state/transition"
require "pq_state/state_machine"
require "pq_state/progress_changer"

require "csv"
require "rails/all"

# This require is necessary to avoid a class error in logstasher.
# This is fixed in HEAD but not currently released in 0.6.1
require "action_mailer/log_subscriber"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ParliamentaryQuestions
  class Application < Rails::Application
    config.defaults = 6.1

    # Application Title (Populates <title>)
    config.app_title = "Parliamentary Questions"

    # Proposition Title (Populates proposition header)
    config.proposition_title = "PQ Tracker"

    # Current Phase (Sets the current phase and the colour of phase tags)
    # Presumed values: alpha, beta, live
    config.phase = "live"

    # Product Type (Adds class to body based on service type)
    # Presumed values: information, service
    config.product_type = "service"

    # Feedback URL (URL for feedback link in phase banner)
    config.feedback_url = "#"

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths << Rails.root.join("lib")

    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.eager_load_paths << Rails.root.join("app/assets/fonts")
    config.eager_load_paths += %w[app/assets/images]
    config.eager_load_paths += %w[app/assets/javascripts]
    config.eager_load_paths += %w[app/assets/stylesheets]
    config.eager_load_paths += %w[app/assets/stylesheets/moj]
    config.eager_load_paths += %w[app/assets/stylesheets/vendor]

    config.generators do |g|
      g.template_engine :erb
    end

    config.exceptions_app = routes

    # Statsd
    $statsd = Statsd.new "localhost", 8125 # rubocop:disable Style/GlobalVars

    # Specify cookies SameSite protection level: either :none, :lax, or :strict.
    #
    # This change is not backwards compatible with earlier Rails versions.
    # It's best enabled when your entire app is migrated and stable on 6.1.
    # Rails.application.config.action_dispatch.cookies_same_site_protection = :lax

    # Generate CSRF tokens that are encoded in URL-safe Base64.
    #
    # This change is not backwards compatible with earlier Rails versions.
    # It's best enabled when your entire app is migrated and stable on 6.1.
    # Rails.application.config.action_controller.urlsafe_csrf_tokens = true
  end
end

require "settings"
