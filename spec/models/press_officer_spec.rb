# == Schema Information
#
# Table name: press_officers
#
#  id            :integer          not null, primary key
#  name          :string
#  email         :string
#  press_desk_id :integer
#  deleted       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require "rails_helper"

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
    let!(:press_officer_today_active) { create(:press_officer, updated_at: Time.zone.now, deleted: false) }
    let!(:press_officer_today_deleted) { create(:press_officer, updated_at: Time.zone.now, deleted: true) }
    let!(:press_officer_yesterday_active) { create(:press_officer, updated_at: 1.day.ago, deleted: false) }
    let!(:press_officer_yesterday_deleted) { create(:press_officer, updated_at: 1.day.ago, deleted: true) }
    let!(:press_officer_three_days_ago_active) { create(:press_officer, updated_at: 3.days.ago, deleted: false) }

    it "lists all active Press Officers and those made inactive withing the last two days" do
      expect(described_class.active_list).to contain_exactly(press_officer_today_active, press_officer_today_deleted, press_officer_yesterday_active, press_officer_yesterday_deleted, press_officer_three_days_ago_active)
    end
  end
end
