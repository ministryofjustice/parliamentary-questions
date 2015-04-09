namespace :db do
  namespace :staging do
    desc 'clones production database to staging and sanitizes emails'
    task :sync => :environment do
      require "#{Rails.root}/lib/rake_task_helpers/db_sanitizer.rb"
]
      RakeTaskHelpers::DBSanitizer.new.run!
      puts 'DB sanitized'

      RakeTaskHelpers::TestUserGenerator.from_config.run!
      put 'Test users created'
    end
  end
end
