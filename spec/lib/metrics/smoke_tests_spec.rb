require 'spec_helper'

describe Metrics::SmokeTests do
  it '#collect! - updates the run time/success fields' do
    allow(SmokeTestRunner).to receive(:run_time).and_return(Time.now)
    allow(SmokeTestRunner).to receive(:run_success?).and_return(true)
    
    subject.collect!

    expect(subject.run_success?).to be true
    expect(subject.run_time).to be_within(1).of(Time.now)
  end
end