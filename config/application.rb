require_relative "boot"
$LOAD_PATH << File.expand_path("../lib", __dir__)

require "pq_state"
require "pq_state/transition"
require "pq_state/state_machine"

require "csv"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
# require "action_cable/engine"
# require "action_mailbox/engine"
require "action_text/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ParliamentaryQuestions
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 6.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #

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

    config.add_autoload_paths_to_load_path = false

    config.generators do |g|
      g.template_engine :erb
    end

    config.exceptions_app = routes

    # Statsd
    $statsd = Statsd.new "localhost", 8125 # rubocop:disable Style/GlobalVars

    # By default associations can be empty
    config.active_record.belongs_to_required_by_default = false

    config.active_support.cache_format_version = 7.1

    config.govuk_time_zone = "UTC"
  end
end

require "settings"
