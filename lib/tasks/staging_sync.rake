namespace :db do
  namespace :staging do
    desc "clones production database to staging and sanitizes emails"
    task sync: :environment do
      RakeTaskHelpers::StagingSync.new.run!
    end

    # as live new questions will be imported daily and current design of UI will make the action
    # of loading pagge slower and slower , this task is to control size of the DB
    # ideally we should change the design of UI.
    desc "trim the size of staging database down"
    task trim: :environment do
      if HostEnv.is_staging?
        begin
          db_trim = RakeTaskHelpers::DbTrim.new
          db_trim.run!
          puts "[+] DB trimmed"
        rescue StandardError => e
          NotifyDbSyncMailer.notify_fail(e.message).deliver_later
        end
      else
        puts "[-] This task should only be run in the staging environment"
        puts "[-] Database has NOT been modified"
      end
    end
  end
end
