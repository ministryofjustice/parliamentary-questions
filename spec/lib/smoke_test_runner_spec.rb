require 'spec_helper'

describe SmokeTestRunner do
  let(:f)        { double File }
  let(:out_file) { "#{Rails.root}#{Settings.smoke_test_runner.out_file}" }

  it '#run! - runs the test suite and records result to file' do
    expect(SmokeTestRunner).to receive(:system)
      .with('bundle exec rspec spec -f p && bundle exec rspec features -f p')
      .and_return(true)
    expect(File).to receive(:open)
      .with(out_file, 'w')
      .and_yield(f)
    expect(f).to receive(:write).with(0)

    SmokeTestRunner.run!
  end

  it '#run_time - returns the timestamp of the last run' do
    now = Time.now

    expect(File).to receive(:ctime).with(out_file).and_return(now)
    expect(SmokeTestRunner.run_time).to eq now
  end

  it '#run_success? - returns whether the last run was successful' do
    allow(File).to receive(:exists?).with(out_file).and_return(true)

    expect(File).to receive(:read).with(out_file).and_return('0')
    expect(SmokeTestRunner.run_success?).to eq true

    expect(File).to receive(:read).with(out_file).and_return('1')
    expect(SmokeTestRunner.run_success?).to eq false
  end
end