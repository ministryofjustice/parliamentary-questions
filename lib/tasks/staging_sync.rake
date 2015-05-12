namespace :db do
  namespace :staging do
    desc 'clones production database to staging and sanitizes emails'
    task :sync => :environment do
      RakeTaskHelpers::StagingSync.new.run!
    end
  end
end
