require "spec_helper"

describe SmokeTestRunner do
  let(:f)        { double File }
  let(:out_file) { "#{Rails.root}#{Settings.smoke_test_runner.out_file}" }

  before do
    ENV["TEST_USER"]      = "me"
    ENV["TEST_USER_PASS"] = "123"

    allow(Settings).to receive(:live_url).and_return("http://localhost")
  end

  it "#run! - runs the test suite and records result to file" do
    test = double SmokeTest::Base, passed?: true
    allow(SmokeTest).to receive(:factory).and_return([test])
    allow(File).to receive(:open).with(out_file, "w").and_yield(f)
    expect(SmokeTest).to receive(:factory)
    expect(File).to receive(:open).with(out_file, "w")
    expect(f).to receive(:write).with(0)

    described_class.run!
  end

  it "#run_time - returns the timestamp of the last run" do
    now = Time.zone.now
    allow(File).to receive(:exist?).with(out_file).and_return(true)
    allow(File).to receive(:ctime).with(out_file).and_return(now)
    expect(File).to receive(:ctime).with(out_file)
    expect(described_class.run_time).to eq now
  end

  it "#run_success? - returns whether the last run was successful" do
    allow(File).to receive(:exist?).with(out_file).and_return(true)
    allow(File).to receive(:read).with(out_file).and_return("0")
    expect(File).to receive(:read).with(out_file)
    expect(described_class.run_success?).to eq true
    allow(File).to receive(:read).with(out_file).and_return("1")
    expect(File).to receive(:read).with(out_file)
    expect(described_class.run_success?).to eq false
  end
end
