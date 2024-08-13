# == Schema Information
#
# Table name: divisions
#
#  id             :integer          not null, primary key
#  name           :string
#  directorate_id :integer
#  deleted        :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require "rails_helper"

describe Division do
  let!(:directorate) { create :directorate }
  let(:div)          { build :division, directorate: }

  it { is_expected.to validate_presence_of(:name) }

  it "passes factory build" do
    expect(div).to be_valid
  end

  it "has a directorate" do
    div.directorate_id = nil
    expect(div).to be_invalid
  end

  describe "associations" do
    it "has a directorate attribute" do
      expect(div).to respond_to(:directorate)
    end

    it "has a collection of Deputy directors" do
      expect(div).to respond_to(:deputy_directors)
    end
  end

  describe "Get index" do
    let!(:division_today_active) { create(:division, updated_at: Time.zone.now, deleted: false) }
    let!(:division_today_deleted) { create(:division, updated_at: Time.zone.now, deleted: true) }
    let!(:division_yesterday_active) { create(:division, updated_at: 1.day.ago, deleted: false) }
    let!(:division_yesterday_deleted) { create(:division, updated_at: 1.day.ago, deleted: true) }
    let!(:division_three_days_ago_active) { create(:division, updated_at: 3.days.ago, deleted: false) }

    it "lists all active Divisions and those made inactive withing the last two days" do
      expect(described_class.active_list).to contain_exactly(division_today_active, division_today_deleted, division_yesterday_active, division_yesterday_deleted, division_three_days_ago_active)
    end
  end
end
