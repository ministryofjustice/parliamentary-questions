require "spec_helper"

describe MetricsDashboard do
  let(:dash) { described_class.new }

  it "#initialize - creates a metrics dashboard with a gecko collection and components" do
    expect(dash.gecko).to be_an_instance_of GeckoCollection
    expect(dash.metrics.key_metric).to be_an_instance_of Metrics::KeyMetric
    expect(dash.metrics.health).to be_an_instance_of Metrics::Health
    expect(dash.metrics.application).to be_an_instance_of Metrics::Application
    expect(dash.metrics.smoke_tests).to be_an_instance_of Metrics::SmokeTests
    expect(dash.metrics.mail).to be_an_instance_of Metrics::Mail
    expect(dash.metrics.pqa_import).to be_an_instance_of Metrics::PqaImport
  end

  it "#update - gathers metric and updates the gecko collection" do
    expect(dash.gecko).to receive(:update).with(dash.metrics)
    expect(dash.metrics.each).to all(receive(:collect!))
    dash.update!
  end
end
