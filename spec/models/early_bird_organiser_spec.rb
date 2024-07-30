# == Schema Information
#
# Table name: early_bird_organisers
#
#  id         :bigint           not null, primary key
#  date_from  :date
#  date_to    :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe EarlyBirdOrganiser, type: :model do
  let(:organiser) { build_stubbed(:early_bird_organiser) }

  describe "validation" do
    it "passes onfactory build" do
      expect(organiser).to be_valid
    end

    it 'has a "date from"' do
      organiser.date_from = nil
      expect(organiser).to be_invalid
    end

    it 'has a "date to"' do
      organiser.date_to = nil
      expect(organiser).to be_invalid
    end

    it 'does not have a "date to" that is before a "date from"' do
      organiser.date_from = Time.zone.today + 5
      organiser.date_to = Time.zone.today - 5

      expect(organiser).to be_invalid
    end

    it "does not have a from data that is in the past" do
      organiser.date_from = Time.zone.today - 5
      organiser.date_to = Time.zone.today + 5

      expect(organiser).to be_invalid
    end
  end
end
