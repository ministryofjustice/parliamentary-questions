namespace :email do
  desc 'Adds emails from db to a queue and attempts to send, logging failures'
  task :process_queue => :environment do
    ImportWorker.new.run!
  end
end