module SmokeTestRunner
  extend self

  def run!
    exit_code = system('bundle exec rspec spec -f p && bundle exec rspec features -f p') ? 0 : 1

    File.open(out_file, 'w') { |f| f.write(exit_code) }
  end

  def run_time
    File.exists?(out_file) ? File.ctime(out_file) : 'N/A'
  end

  def run_success?
    File.exists?(out_file) && File.read(out_file).to_i == 0
  end

  private

  def out_file
    @out_file ||= "#{Rails.root}#{Settings.smoke_test_runner.out_file}"
  end
end