require 'spec_helper'

describe MetricsDashboard do
  let(:dash) { MetricsDashboard.new }

  it '#initialize - creates a metrics dashboard with a gecko collection and components' do
    expect(dash.gecko).to be_an_instance_of GeckoCollection
    expect(dash.components.key_metric).to be_an_instance_of MetricsDashboard::KeyMetric
    expect(dash.components.health).to be_an_instance_of MetricsDashboard::Health
    expect(dash.components.app_info).to be_an_instance_of MetricsDashboard::AppInfo
    expect(dash.components.smoke_test_info).to be_an_instance_of MetricsDashboard::SmokeTestInfo
    expect(dash.components.mail_info).to be_an_instance_of MetricsDashboard::MailInfo
    expect(dash.components.pqa_import_info).to be_an_instance_of MetricsDashboard::PqaImportInfo
  end

  it '#update - gathers metric and updates the gecko collection' do
    expect(dash.gecko).to receive(:update).with(dash.components)
    
    dash.components.each do |c|
      expect(c).to receive(:gather_metrics)
    end

    dash.update
  end
end