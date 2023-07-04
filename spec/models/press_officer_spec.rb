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

require "spec_helper"

describe PressOfficer do
  let(:pdesk)    { create(:press_desk) }
  let(:pofficer) { build(:press_officer, press_desk: pdesk) }

  it { is_expected.to validate_presence_of(:name) }

  it "passes factory build" do
    expect(pofficer).to be_valid
  end

  it "has a press desk" do
    pofficer.press_desk_id = nil
    expect(pofficer).to be_invalid
  end

  describe "associations" do
    it { is_expected.to belong_to :press_desk }
  end

  describe "Get index" do
    let!(:pressOfficer1) { create(:press_officer, updated_at: Time.zone.now, deleted: false) }
    let!(:pressOfficer2) { create(:press_officer, updated_at: Time.zone.now, deleted: true) }
    let!(:pressOfficer3) { create(:press_officer, updated_at: 1.day.ago, deleted: false) }
    let!(:pressOfficer4) { create(:press_officer, updated_at: 1.day.ago, deleted: true) }
    let!(:pressOfficer5) { create(:press_officer, updated_at: 3.days.ago, deleted: false) }
    let!(:pressOfficer6) { create(:press_officer, updated_at: 3.days.ago, deleted: true) }

    it "lists all active Press Officers and those made inactive withing the last two days" do
      expect(described_class.active_list).to match_array [pressOfficer1, pressOfficer2, pressOfficer3, pressOfficer4, pressOfficer5]
    end
  end
end
