# == Schema Information
#
# Table name: press_officers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  email         :string(255)
#  press_desk_id :integer
#  deleted       :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe PressOfficer do
	let(:pofficer) {build(:press_officer)}

	it { should validate_presence_of(:name) }

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
