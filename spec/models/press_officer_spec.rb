require 'spec_helper'

describe PressOfficer do
	let(:pofficer) {build(:press_officer)}

	it 'should pass factory build' do
		expect(pofficer).to be_valid
	end

	it 'should have a press desk' do
		pofficer.press_desk_id = nil
		expect(pofficer).to be_invalid
  end

  describe "associations" do
    it { is_expected.to belong_to :press_desk }
  end
end
