require "spec_helper"

describe GeckoCollection do
  subject(:collection) { described_class.new }

  let(:all_components) { %i[key_metric db pqa_api pqa_import smoke_tests] }

  it "#initialize - should be initialized with gecko status instances" do
    expect(collection.key_metric).to be_an_instance_of(KeyMetricStatus)
    expect(collection.db).to be_an_instance_of(DbStatus)
    expect(collection.pqa_api).to be_an_instance_of(PqaApiStatus)
    expect(collection.pqa_import).to be_an_instance_of(PqaImportStatus)
    expect(collection.smoke_tests).to be_an_instance_of(SmokeTestStatus)
  end

  it "#each - should iterate through the GeckoStatus objects in the expected order" do
    component_names = []
    collection.each do |status|
      component_names << status.name
    end

    expect(component_names).to eq ["Key Metric", "Database", "PQA API", "PQ Import", "Smoke Tests"]
  end

  it "#map - should iterate through the GeckoStatus objects in the expected order" do
    component_names = collection.map(&:name)

    expect(component_names).to eq ["Key Metric", "Database", "PQA API", "PQ Import", "Smoke Tests"]
  end

  it "#update - should update each gecko status instance" do
    comp = instance_double Metrics::Component
    components = [comp, comp]

    all_components.each do |component|
      expect(collection.send(component)).to receive(:update).with(components)
    end

    collection.update(components) # rubocop:disable Rails/SaveBang
  end
end
