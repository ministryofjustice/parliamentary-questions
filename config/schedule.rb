# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever
#
set :output, 'log/schedule.log'
#job_type :rake,  'cd :path && RAILS_ENV=production bundle exec rake :task :output'
#
# Run smoke tests every hour
#
every 1.hour do
  rake 'smoke_test:run'
end
