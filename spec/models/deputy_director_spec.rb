require 'spec_helper'

describe DeputyDirector do
	let(:depdir) {build(:deputy_director)}
	
	it { should validate_presence_of(:name) }

	it 'should pass factory build' do
		expect(depdir).to be_valid
	end

	it 'should have a division' do
		depdir.division_id = nil
		expect(depdir).to be_invalid
	end

  describe "associations" do
    it "should have a division attribute" do
      expect(depdir).to respond_to(:division)
    end

    it 'should have a collection of action officers' do
      expect(depdir).to respond_to(:action_officers)
    end
  end
end
