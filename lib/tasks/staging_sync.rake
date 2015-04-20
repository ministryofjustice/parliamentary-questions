namespace :db do
  namespace :staging do
    desc 'clones production database to staging and sanitizes emails'
    task :sync => :environment do
      require "#{Rails.root}/lib/rake_task_helpers/db_sanitizer.rb"
      require "#{Rails.root}/lib/rake_task_helpers/test_user_generator.rb"

      if HostEnv.is_staging?
        RakeTaskHelpers::DBSanitizer.new.run!
        puts '[+] DB sanitized'

        RakeTaskHelpers::TestUserGenerator.from_config.run!
        puts '[+] Test users created'
        puts '[+] Done'
      else
        puts '[-] This task should only be run in the staging environment'
        puts '[-] Database has NOT been modified'
      end
    end
  end
end
