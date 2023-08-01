require "spec_helper"

describe GeckoReport do
  let(:gecko) { described_class.new }

  it "#initialize - creates items for gecko" do
    expect(gecko).to be_an_instance_of described_class
  end
end
