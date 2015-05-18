namespace :smoke_test do
  desc 'Run the feature unit tests in staging and production'
  task :run => :environment do
    puts '[+] Running smoke tests...'
    SmokeTestRunner.run!
  end
end