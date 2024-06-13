namespace :pqa do
  desc "Queue Early Bird Emails"
  task :early_bird, [] => :environment do
    if PQAImportRun.ready_for_early_bird

      organiser = EarlyBirdOrganiser.last
      if organiser
        date_from = organiser.date_from
        date_to = organiser.date_to
      else
        date_from = Date.new(2021, 5, 29)
        date_to = Date.new(2021, 6, 6)
      end

      if Time.zone.today < date_from || (Time.zone.today > date_to)
        LogStuff.info { "Early Bird: Preparing to queue early bird mails" }
        service = EarlyBirdReportService.new
        service.notify_early_bird
        LogStuff.info { "Early Bird: mails queued" }
        puts "Early Bird: mails queued"
      else
        LogStuff.info { "Early Bird: Should not run - We are in a recess" }
        puts "Early Bird: Should not run - We are in a recess"
      end
    else
      LogStuff.info { "Early Bird: Did not run - PQAImportRun.ready_for_early_bird returned false" }
      puts "Early Bird: Did not run - PQAImportRun.ready_for_early_bird returned false"
    end
  rescue StandardError => e
    LogStuff.error { "Early Bird: #{e.message}" }
    puts "Early Bird:#{e.message}"
    raise e
  end
end
