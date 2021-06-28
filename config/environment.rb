# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

dbconfig = Rails.configuration.database_configuration[Rails.env]
LogStuff.info "Connecting to #{dbconfig['adapter']} database #{dbconfig['database']} on #{dbconfig['host']}"

smtpconfig = ActionMailer::Base.smtp_settings.reject { |x| x['password'] }
LogStuff.info "ActionMailer smtp_settings #{smtpconfig.inspect}"
LogStuff.info "ActionMailer base_config #{ActionMailer::Base.default.inspect}"
