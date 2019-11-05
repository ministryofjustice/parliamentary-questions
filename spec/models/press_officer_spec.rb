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
  let(:pofficer) { create(:press_officer) }

  it { should validate_presence_of(:name) }

  it 'should pass factory build' do
    expect(pofficer).to be_valid
  end

  it 'should have a press desk' do
    pofficer.press_desk_id = nil
    expect(pofficer).to be_invalid
  end

  describe 'associations' do
    it { is_expected.to belong_to :press_desk }
  end

  describe 'Get index' do
    let!(:pressOfficer1) { create(:press_officer, updated_at: DateTime.now.to_datetime, deleted: false) }
    let!(:pressOfficer2) { create(:press_officer, updated_at: DateTime.now.to_datetime, deleted: true) }
    let!(:pressOfficer3) { create(:press_officer, updated_at: 1.day.ago.to_datetime,    deleted: false) }
    let!(:pressOfficer4) { create(:press_officer, updated_at: 1.day.ago.to_datetime,    deleted: true) }
    let!(:pressOfficer5) { create(:press_officer, updated_at: 3.days.ago.to_datetime,   deleted: false) }
    let!(:pressOfficer6) { create(:press_officer, updated_at: 3.days.ago.to_datetime,   deleted: true) }

    it 'lists all active Press Officers and those made inactive withing the last two days' do
      expect(PressOfficer.active_list).to match_array [pressOfficer1, pressOfficer2, pressOfficer3, pressOfficer4, pressOfficer5]
    end
  end
end
