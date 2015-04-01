require 'spec_helper'

describe Division do
	let(:div) { build(:division) }

	it { should validate_presence_of(:name) }

	it 'should pass factory build' do
		expect(div).to be_valid
	end

	it 'should have a directorate' do
		div.directorate_id = nil
		expect(div).to be_invalid
	end

  describe "associations" do
    it "should have a directorate attribute" do
      expect(div).to respond_to(:directorate)
    end

   	it 'should have a collection of Deputy directors' do
   expect(div).to respond_to(:deputy_directors)
   	end
  end
end
