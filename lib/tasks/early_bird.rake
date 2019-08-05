namespace :pqa do
  desc 'Queue Early Bird Emails'
  task :early_bird, [] => :environment do
    begin
        if PqaImportRun.ready_for_early_bird
          if (Time.zone.today < Date.new(2019, 8, 5)) || (Time.zone.today > Date.new(2019, 9, 2))
            LogStuff.info { 'Early Bird: Preparing to queue early bird mails' }
            service = EarlyBirdReportService.new
            service.notify_early_bird
            LogStuff.info { 'Early Bird: mails queued' }
            puts 'Early Bird: mails queued'
          else
            LogStuff.info { 'Early Bird: Should not run - We are in a recess' }
            puts 'Early Bird: Should not run - We are in a recess'
          end
        else
          LogStuff.info { 'Early Bird: Did not run - PqaImportRun.ready_for_early_bird returned false' }
          puts 'Early Bird: Did not run - PqaImportRun.ready_for_early_bird returned false'
        end
    rescue => err
      LogStuff.error { 'Early Bird: ' + err.message }
      puts 'Early Bird:' + err.message
      raise err
      end
  end
end
