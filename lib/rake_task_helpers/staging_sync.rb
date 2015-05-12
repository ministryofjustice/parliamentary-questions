module RakeTaskHelpers
  class StagingSync
    def initialize
      @db_sanitizer   = RakeTaskHelpers::DBSanitizer.new
      @user_generator = RakeTaskHelpers::TestUserGenerator.from_config
    end

    def run!
      if HostEnv.is_staging?
        begin
          @db_sanitizer.run!
          puts '[+] DB sanitized'

          @user_generator.run!
          puts '[+] Test users created'
          puts '[+] Done'
        rescue => err
          MailService::DbSync.notify_fail(err.message)
        end
      else
        puts '[-] This task should only be run in the staging environment'
        puts '[-] Database has NOT been modified'
      end
    end
  end
end
