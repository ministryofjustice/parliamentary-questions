# == Schema Information
#
# Table name: early_bird_members
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  deleted    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

describe EarlyBirdMember do
  let(:member) { build(:early_bird_member) }

  describe "validation" do
    it "passes onfactory build" do
      expect(member).to be_valid
    end

    it "has a name" do
      member.name = nil
      expect(member).to be_invalid
    end

    it "has a unique email" do
      create(:early_bird_member, name: "Early Bird Member 1", email: "member.one@earlybird.com")
      duplicate = build(:early_bird_member, name: "Early Bird Member 2", email: "member.one@earlybird.com")
      expect(duplicate).to be_invalid
    end
  end

  describe "scopes" do
    let!(:eb_today_deleted) { create(:early_bird_member, updated_at: Time.zone.now, deleted: true) }
    let!(:eb_today_active) { create(:early_bird_member, updated_at: Time.zone.now, deleted: false) }
    let!(:eb_yesterday_deleted) { create(:early_bird_member, updated_at: 1.day.ago, deleted: true) }
    let!(:eb_yesterday_active) { create(:early_bird_member, updated_at: 1.day.ago, deleted: false) }
    let!(:eb_three_days_ago_deleted) { create(:early_bird_member, updated_at: 3.days.ago, deleted: true) }
    let!(:eb_three_days_ago_active) { create(:early_bird_member, updated_at: 3.days.ago, deleted: false) }

    it "lists all active Early Bird Members" do
      expect(described_class.active_list).to contain_exactly(eb_today_active, eb_yesterday_active, eb_three_days_ago_active)
    end

    it "lists all inactive Early Bird Members" do
      expect(described_class.inactive_list).to contain_exactly(eb_today_deleted, eb_yesterday_deleted, eb_three_days_ago_deleted)
    end
  end
end
