require 'spec_helper'

describe Metrics::KeyMetric do
  it '#initialize - alert should be set to false' do
    expect(subject.alert).to be false
  end

  it '#collect! - updates the key metric alert field' do
    allow(PqStatistics).to receive(:key_metric_alert?).and_return(true)
    subject.collect!

    expect(subject.alert).to be true
  end
end