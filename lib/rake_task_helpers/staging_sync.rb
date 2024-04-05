module RakeTaskHelpers
  class StagingSync
    def initialize
      @db_trim        = RakeTaskHelpers::DbTrim.new
      @db_sanitizer   = RakeTaskHelpers::DbSanitizer.new
      @user_generator = RakeTaskHelpers::TestUserGenerator.from_config
    end

    def run!
      if HostEnv.is_staging?
        begin
          @db_trim.run!
          puts "[+] DB trimmed"

          @db_sanitizer.run!
          puts "[+] DB sanitized"

          @user_generator.run!
          puts "[+] Test users created"
          puts "[+] Done"
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
