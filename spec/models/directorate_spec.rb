# == Schema Information
#
# Table name: directorates
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Directorate do
  let(:dir) { build(:directorate) }

  it { should validate_presence_of(:name) }

  it 'should pass factory build' do
    expect(dir).to be_valid
  end

  describe 'associations' do
    it 'should have a divisions collection' do
      expect(dir).to respond_to(:divisions)
    end
  end

  describe 'Get index' do
    let!(:directorate1) { create(:directorate, updated_at: DateTime.now.to_datetime, deleted: false) }
    let!(:directorate2) { create(:directorate, updated_at: DateTime.now.to_datetime, deleted: true) }
    let!(:directorate3) { create(:directorate, updated_at: 1.day.ago.to_datetime,    deleted: false) }
    let!(:directorate4) { create(:directorate, updated_at: 1.day.ago.to_datetime,    deleted: true) }
    let!(:directorate5) { create(:directorate, updated_at: 3.days.ago.to_datetime,   deleted: false) }
    let!(:directorate6) { create(:directorate, updated_at: 3.days.ago.to_datetime,   deleted: true) }

    it 'lists all active Directorates and those made inactive withing the last two days' do
      expect(Directorate.active_list).to match_array [directorate1, directorate2, directorate3, directorate4, directorate5]
    end
  end
end
