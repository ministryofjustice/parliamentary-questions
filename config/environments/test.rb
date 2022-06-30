require 'active_support/core_ext/integer/time'

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=3600'

  # Configure public file server for tests with Cache-Control for performance.
  # config.public_file_server.enabled = true
  # config.public_file_server.headers = {
  #   'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  # }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.log_level = :debug

  # Store uploaded files on the local file system in a temporary directory.
  # config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  # This fills in the 'from' field which is required to run feature
  # tests on circleci
  config.action_mailer.default_options = { from: 'localhost' }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
  config.active_job.queue_adapter = :test

  config.after_initialize do
    PaperTrail.enabled = false
  end
  config.after_initialize do
    sending_host = ENV['SENDING_HOST'] || 'localhost'
    ActionMailer::Base.default_url_options = { host: sending_host, protocol: 'https', port: '3000' }
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
