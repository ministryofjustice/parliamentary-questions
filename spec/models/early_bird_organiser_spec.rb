require 'spec_helper'

RSpec.describe EarlyBirdOrganiser, type: :model do
  let(:organiser) { build_stubbed(:early_bird_organiser) }

  describe 'validation' do
    it 'should pass onfactory build' do
      expect(organiser).to be_valid
    end

    it 'it should have a date from' do
      organiser.date_from = nil
      expect(organiser).to be_invalid
    end

    it 'it should have a date to' do
      organiser.date_to = nil
      expect(organiser).to be_invalid
    end

    it 'should not have a date to that is before a date from' do
      organiser.date_from = Date.new(2021, 5, 29)
      organiser.date_to = Date.new(2021, 4, 29)

      expect(organiser).to be_invalid
    end
  end
end
