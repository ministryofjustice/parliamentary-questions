# == Schema Information
#
# Table name: deputy_directors
#
#  id          :integer          not null, primary key
#  name        :string
#  email       :string
#  division_id :integer
#  deleted     :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "rails_helper"

describe DeputyDirector do
  let(:div)    { create :division }
  let(:depdir) { build(:deputy_director, division: div) }

  it { is_expected.to validate_presence_of(:name) }

  it "passes factory build" do
    expect(depdir).to be_valid
  end

  it "has a division" do
    depdir.division_id = nil
    expect(depdir).to be_invalid
  end

  describe "associations" do
    it "has a division attribute" do
      expect(depdir).to respond_to(:division)
    end

    it "has a collection of action officers" do
      expect(depdir).to respond_to(:action_officers)
    end
  end

  describe "Get index" do
    let!(:deputy_director1) { create(:deputy_director, updated_at: Time.zone.now, deleted: false) }
    let!(:deputy_director2) { create(:deputy_director, updated_at: Time.zone.now, deleted: true) }
    let!(:deputy_director3) { create(:deputy_director, updated_at: 1.day.ago, deleted: false) }
    let!(:deputy_director4) { create(:deputy_director, updated_at: 1.day.ago, deleted: true) }
    let!(:deputy_director5) { create(:deputy_director, updated_at: 3.days.ago, deleted: false) }

    it "lists all active Deputy Directors and those made inactive withing the last two days" do
      expect(described_class.active_list).to match_array [deputy_director1, deputy_director2, deputy_director3, deputy_director4, deputy_director5]
    end
  end
end
