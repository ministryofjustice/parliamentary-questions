require 'spec_helper'


describe Ogd do
  let(:ogd) {build(:ogd)}

  it 'should pass factory build' do
    expect(ogd).to be_valid
  end
  it 'should have a name' do
    ogd.name = nil
    expect(ogd).to be_invalid
  end
  it 'should have an Acronym' do
    ogd.acronym = nil
    expect(ogd).to be_invalid
  end

end
