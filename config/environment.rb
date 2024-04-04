# Load the Rails application.
require_relative "application"

# Set up the default settings for active_job
Rails.configuration.active_job.queue_adapter     = :sidekiq
Rails.configuration.active_job.queue_name_prefix = "parliamentary_questions"
Rails.application.config.action_mailer.deliver_later_queue_name = "mailers"

# Initialize the Rails application.
Rails.application.initialize!

dbconfig = Rails.configuration.database_configuration[Rails.env]
LogStuff.info "Connecting to #{dbconfig['adapter']} database #{dbconfig['database']} on #{dbconfig['host']}"
