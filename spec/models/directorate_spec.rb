require 'spec_helper'

describe Directorate do
	let(:dir) {build(:directorate)}

	it { should validate_presence_of(:name) }

	it 'should pass factory build' do
		expect(dir).to be_valid
	end

  describe "associations" do
    it "should have a divisions collection" do
      expect(dir).to respond_to(:divisions)
    end
  end
end
