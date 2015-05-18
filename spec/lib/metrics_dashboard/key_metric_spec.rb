require 'spec_helper'

describe MetricsDashboard::KeyMetric do
  it '#initialize - alert should be set to false' do
    expect(subject.alert).to be false
  end

  it '#gather_metrics - updates the key metric alert field' do
    allow(PqStatistics).to receive(:key_metric_alert?).and_return(true)
    subject.gather_metrics

    expect(subject.alert).to be true
  end
end