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

require 'spec_helper'

describe ActionOfficer do
  let(:officer) { create(:action_officer) }

  it 'should pass factory build' do
    expect(officer).to be_valid
  end

  it 'should have a deputy director' do
    officer.deputy_director_id = nil
    expect(officer).to be_invalid
  end

  it 'should have a press desk' do
    officer.press_desk_id = nil
    expect(officer).to be_invalid
  end

  it 'should strip whitespace from emails' do
    officer.update(email: ' action.officer@new.email.com')
    expect(officer.email).to eql('action.officer@new.email.com')
  end

  describe 'associations' do
    it 'should have a deputy director attribute' do
      expect(officer).to respond_to(:deputy_director)
    end

    it 'should have a collection of assignments' do
      expect(officer).to respond_to(:action_officers_pqs)
    end
  end

  describe 'Get index' do
    let!(:actionOfficer1) { create(:action_officer, updated_at: DateTime.now.to_datetime, deleted: false) }
    let!(:actionOfficer2) { create(:action_officer, updated_at: DateTime.now.to_datetime, deleted: true) }
    let!(:actionOfficer3) { create(:action_officer, updated_at: 1.day.ago.to_datetime,    deleted: false) }
    let!(:actionOfficer4) { create(:action_officer, updated_at: 1.day.ago.to_datetime,    deleted: true) }
    let!(:actionOfficer5) { create(:action_officer, updated_at: 3.days.ago.to_datetime,   deleted: false) }
    let!(:actionOfficer6) { create(:action_officer, updated_at: 3.days.ago.to_datetime,   deleted: true) }

    it 'lists all active Action Officers and those made inactive withing the last two days' do
      expect(ActionOfficer.active_list).to match_array [actionOfficer1, actionOfficer2, actionOfficer3, actionOfficer4, actionOfficer5]
    end
  end
end
