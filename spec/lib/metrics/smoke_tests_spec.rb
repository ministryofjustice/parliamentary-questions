require "spec_helper"

describe Metrics::SmokeTests do
  subject(:smoke_tests) { described_class.new }

  it "#collect! - updates the run time/success fields" do
    allow(SmokeTestRunner).to receive(:run_time).and_return(Time.zone.now)
    allow(SmokeTestRunner).to receive(:run_success?).and_return(true)

    smoke_tests.collect!

    expect(smoke_tests.run_success?).to be true
    expect(smoke_tests.run_time).to be_within(1).of(Time.zone.now)
  end
end
