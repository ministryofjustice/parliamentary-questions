# This task is mainly for trimming down size of DB and anonymising the users' information
# For non-staging env. Not sure why its name contains 'Sync'? which cause confusing
# Right now it is designed to run on daily baisis which I couldn't see the point
# if there is no importing action against the following tables from live env on daily basis
module RakeTaskHelpers
  class StagingSync
    def initialize
      @db_trim        = RakeTaskHelpers::DBTrim.new
      @db_sanitizer   = RakeTaskHelpers::DBSanitizer.new
      @user_generator = RakeTaskHelpers::TestUserGenerator.from_config
    end

    def run!
      if HostEnv.is_staging?
        begin
          @db_trim.run!
          puts '[+] DB trimmed'

          @db_sanitizer.run!
          puts '[+] DB sanitized'

          @user_generator.run!
          puts '[+] Test users created'
          puts '[+] Done'
        rescue => e
          NotifyDbSyncMailer.notify_fail(e.message).deliver_now
        end
      else
        puts '[-] This task should only be run in the staging environment'
        puts '[-] Database has NOT been modified'
      end
    end
  end
end
