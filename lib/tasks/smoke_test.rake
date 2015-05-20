namespace :smoke_test do
  desc 'Run the smoke tests in staging and live'
  task :run => :environment do
    if HostEnv.is_staging? || HostEnv.is_live?
      puts '[+] Running smoke tests...'
      SmokeTestRunner.run!
    else
      puts '[-] Task will only be run on staging or live environments'
    end
  end
end