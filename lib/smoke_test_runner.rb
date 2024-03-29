module SmokeTestRunner
  extend self

  def run!
    tests     = SmokeTest.factory
    exit_code = tests.all?(&:passed?) ? 0 : 1

    File.open(out_file, "w") { |f| f.write(exit_code) }
  end

  def run_time
    File.exist?(out_file) ? File.ctime(out_file) : Time.zone.at(0)
  end

  def run_success?
    File.exist?(out_file) && File.read(out_file).to_i.zero?
  end

private

  def out_file
    @out_file ||= "#{Rails.root}#{Settings.smoke_test_runner.out_file}"
  end
end
