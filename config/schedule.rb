# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever
#
set :output, 'log/schedule.log'
job_type :rake,  "cd :path && RAILS_ENV=production bundle exec rake :task :output"
#
# PQ API Nightly Import
#
every 1.day, :at => '4:00 am' do
  rake 'pqa:nightly_import'
end

every 1.day, :at => '6:00 am' do
  rake 'pqa:nightly_import'
end
#
# PQ Early Bird email (schedule after the first of the nightly imports)
#
every 1.day, :at => '5:30 am' do
  rake 'pqa:early_bird'
end
#
# Sanitize imported staging data
# Follows import job staging -> production run via crontab
#
every 1.day, :at => '1:00 am' do
  rake 'db:staging:sync'
end
#
# Trigger mail queue poll and new email sending
#
every 1.minute do
  rake 'email:process_queue'
end
#
# Run smoke tests every hour
#
every 1.hour do
  rake 'smoke_test:run'
end

