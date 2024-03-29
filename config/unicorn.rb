n = Integer(ENV["WEB_CONCURRENCY"] || 4)
worker_processes(n)

before_fork do |_, _|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

after_fork do |_, _|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end
