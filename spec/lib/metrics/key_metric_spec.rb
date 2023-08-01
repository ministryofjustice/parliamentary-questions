require "spec_helper"

describe Metrics::KeyMetric do
  subject(:key_metric) { described_class.new }

  it "#initialize - alert should be set to false" do
    expect(key_metric.alert).to be false
  end

  it "#collect! - updates the key metric alert field" do
    allow(PqStatistics).to receive(:key_metric_alert?).and_return(true)
    key_metric.collect!

    expect(key_metric.alert).to be true
  end
end
