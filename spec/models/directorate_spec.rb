# == Schema Information
#
# Table name: directorates
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe Directorate do
  let(:dir) { build(:directorate) }

  it { is_expected.to validate_presence_of(:name) }

  it "passes factory build" do
    expect(dir).to be_valid
  end

  describe "associations" do
    it "has a divisions collection" do
      expect(dir).to respond_to(:divisions)
    end
  end

  describe "Get index" do
    let!(:directorate_today_deleted) { create(:directorate, updated_at: Time.zone.now, deleted: false) }
    let!(:directorate_today_active) { create(:directorate, updated_at: Time.zone.now, deleted: true) }
    let!(:directorate_yesterday_active) { create(:directorate, updated_at: 1.day.ago, deleted: false) }
    let!(:directorate_yesterday_deleted) { create(:directorate, updated_at: 1.day.ago, deleted: true) }
    let!(:directorate_three_days_ago_active) { create(:directorate, updated_at: 3.days.ago, deleted: false) }

    it "lists all active Directorates and those made inactive withing the last two days" do
      expect(described_class.active_list).to contain_exactly(directorate_today_deleted, directorate_today_active, directorate_yesterday_active, directorate_yesterday_deleted, directorate_three_days_ago_active)
    end
  end
end
