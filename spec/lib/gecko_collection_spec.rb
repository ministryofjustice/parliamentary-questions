require "spec_helper"

describe GeckoCollection do
  let(:all_components) { %i[key_metric db pqa_api pqa_import smoke_tests] }

  it "#initialize - should be initialized with gecko status instances" do
    expect(subject.key_metric).to be_an_instance_of(KeyMetricStatus)
    expect(subject.db).to be_an_instance_of(DbStatus)
    expect(subject.pqa_api).to be_an_instance_of(PqaApiStatus)
    expect(subject.pqa_import).to be_an_instance_of(PqaImportStatus)
    expect(subject.smoke_tests).to be_an_instance_of(SmokeTestStatus)
  end

  it "#each - should iterate through the GeckoStatus objects in the expected order" do
    component_names = []
    subject.each do |status|
      component_names << status.name
    end

    expect(component_names).to eq ["Key Metric", "Database", "PQA API", "PQ Import", "Smoke Tests"]
  end

  it "#map - should iterate through the GeckoStatus objects in the expected order" do
    component_names = subject.map(&:name)

    expect(component_names).to eq ["Key Metric", "Database", "PQA API", "PQ Import", "Smoke Tests"]
  end

  it "#update - should update each gecko status instance" do
    component  = double Metrics::Component
    components = [component, component]

    all_components.each do |component|
      expect(subject.send(component)).to receive(:update).with(components)
    end

    subject.update(components) # rubocop:disable Rails/SaveBang
  end
end
