if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.environment = ENV["ENV"]
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [:active_support_logger]
  end
end
