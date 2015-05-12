namespace :email do
  desc 'Adds emails from db to a queue and attempts to send, logging failures'
  task :process_queue => :environment do
    MailWorker.new.run!
  end
end