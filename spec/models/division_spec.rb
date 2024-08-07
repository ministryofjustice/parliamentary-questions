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
    let!(:division1) { create(:division, updated_at: Time.zone.now, deleted: false) }
    let!(:division2) { create(:division, updated_at: Time.zone.now, deleted: true) }
    let!(:division3) { create(:division, updated_at: 1.day.ago, deleted: false) }
    let!(:division4) { create(:division, updated_at: 1.day.ago, deleted: true) }
    let!(:division5) { create(:division, updated_at: 3.days.ago, deleted: false) }

    it "lists all active Divisions and those made inactive withing the last two days" do
      expect(described_class.active_list).to match_array [division1, division2, division3, division4, division5]
    end
  end
end
