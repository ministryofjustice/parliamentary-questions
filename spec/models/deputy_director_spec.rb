# == Schema Information
#
# Table name: deputy_directors
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  email       :string(255)
#  division_id :integer
#  deleted     :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#

require "spec_helper"

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
    let!(:deputyDirector1) { create(:deputy_director, updated_at: Time.zone.now, deleted: false) }
    let!(:deputyDirector2) { create(:deputy_director, updated_at: Time.zone.now, deleted: true) }
    let!(:deputyDirector3) { create(:deputy_director, updated_at: 1.day.ago, deleted: false) }
    let!(:deputyDirector4) { create(:deputy_director, updated_at: 1.day.ago, deleted: true) }
    let!(:deputyDirector5) { create(:deputy_director, updated_at: 3.days.ago, deleted: false) }
    let!(:deputyDirector6) { create(:deputy_director, updated_at: 3.days.ago, deleted: true) }

    it "lists all active Deputy Directors and those made inactive withing the last two days" do
      expect(described_class.active_list).to match_array [deputyDirector1, deputyDirector2, deputyDirector3, deputyDirector4, deputyDirector5]
    end
  end
end
