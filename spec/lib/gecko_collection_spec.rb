require 'spec_helper'

describe GeckoCollection do
  let(:all_components) { [:key_metric, :db, :sendgrid, :pqa_api, :mail, :pqa_import, :smoke_tests] }
  
  it '#initialize - should be initialized with gecko status instances' do
    expect(subject.key_metric).to be_an_instance_of(KeyMetricStatus)
    expect(subject.db).to be_an_instance_of(DbStatus)
    expect(subject.sendgrid).to be_an_instance_of(SendgridStatus)
    expect(subject.pqa_api).to be_an_instance_of(PqaApiStatus)
    expect(subject.mail).to be_an_instance_of(MailStatus)
    expect(subject.pqa_import).to be_an_instance_of(PqaImportStatus)
    expect(subject.smoke_tests).to be_an_instance_of(SmokeTestStatus)
  end 

  it '#each - should iterate through the GeckoStatus objects in the expected order' do
    component_names = []
    subject.each do |status| 
      component_names << status.name
    end

    expect(component_names).to eq ['Key Metric', 'Database', 'Sendgrid', 'PQA API', 'Email', 'PQ Import', 'Smoke Tests']
  end

  it '#map - should iterate through the GeckoStatus objects in the expected order' do
    component_names = subject.map { |status| status.name }

    expect(component_names).to eq ['Key Metric', 'Database', 'Sendgrid', 'PQA API', 'Email', 'PQ Import', 'Smoke Tests']
  end

  it '#update - should update each gecko status instance' do
    component  = double MetricsDashboard::Component
    components = [ component, component ]

    all_components.each do |component| 
      expect(subject.send(component)).to receive(:update).with(components) 
    end

    subject.update(components)
  end
end


