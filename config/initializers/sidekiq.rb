require 'sidekiq/web'

if Rails.env.production?
  Sidekiq.logger.formatter = Sidekiq::Logger::Formatters::JSON.new
end

Sidekiq.configure_client do |config|
  config.redis = {
    size: 1
  }
end

Sidekiq::Extensions.enable_delay!
