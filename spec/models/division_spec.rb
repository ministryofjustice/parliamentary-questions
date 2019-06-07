# == Schema Information
#
# Table name: divisions
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  directorate_id :integer
#  deleted        :boolean          default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe Division do
  let!(:directorate) { create :directorate }
  let(:div)          { build :division, directorate: directorate }

  it { should validate_presence_of(:name) }

  it 'should pass factory build' do
    expect(div).to be_valid
  end

  it 'should have a directorate' do
    div.directorate_id = nil
    expect(div).to be_invalid
  end

  describe 'associations' do
    it 'should have a directorate attribute' do
      expect(div).to respond_to(:directorate)
    end

    it 'should have a collection of Deputy directors' do
      expect(div).to respond_to(:deputy_directors)
    end
  end

  describe 'Get index' do
    let!(:division1) { create(:division, updated_at: DateTime.now.to_datetime, deleted: false) }
    let!(:division2) { create(:division, updated_at: DateTime.now.to_datetime, deleted: true) }
    let!(:division3) { create(:division, updated_at: 1.day.ago.to_datetime,    deleted: false) }
    let!(:division4) { create(:division, updated_at: 1.day.ago.to_datetime,    deleted: true) }
    let!(:division5) { create(:division, updated_at: 3.days.ago.to_datetime,   deleted: false) }
    let!(:division6) { create(:division, updated_at: 3.days.ago.to_datetime,   deleted: true) }

    it 'lists all active Divisions and those made inactive withing the last two days' do
      expect(Division.active_list).to match_array [division1, division2, division3, division4, division5]
    end
  end
end
