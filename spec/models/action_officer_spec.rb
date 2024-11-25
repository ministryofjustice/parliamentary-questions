# == Schema Information
#
# Table name: action_officers
#
#  id                 :integer          not null, primary key
#  name               :string
#  email              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted            :boolean          default(FALSE)
#  phone              :string
#  deputy_director_id :integer
#  press_desk_id      :integer
#  group_email        :string
#

require "rails_helper"

describe ActionOfficer do
  let(:rita_skeeter) { create :press_desk }
  let(:maud_dib)     { create :deputy_director }
  let(:officer)      { build(:action_officer, press_desk: rita_skeeter, deputy_director: maud_dib) }

  it "passes factory build" do
    expect(officer).to be_valid
  end

  it "has a deputy director" do
    officer.deputy_director_id = nil
    expect(officer).to be_invalid
  end

  it "has a press desk" do
    officer.press_desk_id = nil
    expect(officer).to be_invalid
  end

  it "strips whitespace from emails" do
    officer.update!(email: " action.officer@new.email.com")
    expect(officer.email).to eql("action.officer@new.email.com")
  end

  describe "associations" do
    it "has a deputy director attribute" do
      expect(officer).to respond_to(:deputy_director)
    end

    it "has a collection of assignments" do
      expect(officer).to respond_to(:action_officers_pqs)
    end
  end

  describe "scopes" do
    let!(:ao_today_deleted) { create(:action_officer, updated_at: Time.zone.now, deleted: true) }
    let!(:ao_today_active) { create(:action_officer, updated_at: Time.zone.now, deleted: false) }
    let!(:ao_yesterday_deleted) { create(:action_officer, updated_at: 1.day.ago, deleted: true) }
    let!(:ao_yesterday_active) { create(:action_officer, updated_at: 1.day.ago, deleted: false) }
    let!(:ao_three_days_ago_deleted) { create(:action_officer, updated_at: 3.days.ago, deleted: true) }
    let!(:ao_three_days_ago_active) { create(:action_officer, updated_at: 3.days.ago, deleted: false) }

    it "lists all active Action Officers" do
      expect(described_class.active_list).to contain_exactly(ao_today_active, ao_yesterday_active, ao_three_days_ago_active)
    end

    it "lists all inactive Action Officers" do
      expect(described_class.inactive_list).to contain_exactly(ao_today_deleted, ao_yesterday_deleted, ao_three_days_ago_deleted)
    end
  end
end
