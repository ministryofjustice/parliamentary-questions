# == Schema Information
#
# Table name: action_officers
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  deleted            :boolean          default(FALSE)
#  phone              :string(255)
#  deputy_director_id :integer
#  press_desk_id      :integer
#  group_email        :string(255)
#

require "spec_helper"

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

  describe "Get index" do
    let!(:action_officer1) { create(:action_officer, updated_at: Time.zone.now, deleted: false) }
    let!(:action_officer2) { create(:action_officer, updated_at: Time.zone.now, deleted: true) }
    let!(:action_officer3) { create(:action_officer, updated_at: 1.day.ago,    deleted: false) }
    let!(:action_officer4) { create(:action_officer, updated_at: 1.day.ago,    deleted: true) }
    let!(:action_officer5) { create(:action_officer, updated_at: 3.days.ago,   deleted: false) }
    let!(:action_officer6) { create(:action_officer, updated_at: 3.days.ago,   deleted: true) }

    it "lists all active Action Officers and those made inactive withing the last two days" do
      expect(described_class.active_list).to match_array [action_officer1, action_officer2, action_officer3, action_officer4, action_officer5]
    end

    it "lists all inactive Action Officers" do
      expect(described_class.inactive_list).to match_array [action_officer2, action_officer4, action_officer6]
    end
  end
end
