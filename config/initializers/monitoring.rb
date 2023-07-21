ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  controller = event.payload[:controller]
  action = event.payload[:action]
  event.payload[:path]
  page_duration = event.duration
  view_duration = event.payload[:view_runtime]
  db_duration = event.payload[:db_runtime]

  key = "#{StatsHelper::PAGES_TIMING}.#{controller}.#{action}"
  key = key.underscore

  $statsd.timing("#{key}.page", page_duration) # rubocop:disable Style/GlobalVars
  $statsd.timing("#{key}.view", view_duration) # rubocop:disable Style/GlobalVars
  $statsd.timing("#{key}.db", db_duration) # rubocop:disable Style/GlobalVars
end
