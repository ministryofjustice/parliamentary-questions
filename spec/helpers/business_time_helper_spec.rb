require 'spec_helper'

describe BusinessTimeHelpers  do 
  context '#calendar' do
    it 'should return an instance of a UK HolidayCalendar' do
      expect(BusinessTimeHelpers.calendar).to be_an_instance_of HolidayCalendar
      expect(BusinessTimeHelpers.calendar.territory).to eq :uk
    end
  end

  context '#load_holidays' do
    it 'should return an array of holiday dates' do
      allow(BusinessTimeHelpers).to receive(:years_to_load).and_return([2014])

      expect(BusinessTimeHelpers.load_holidays).to eq(
        [
          'Wed, 01 Jan 2014',
          'Fri, 18 Apr 2014',
          'Mon, 21 Apr 2014',
          'Mon, 05 May 2014',
          'Mon, 26 May 2014',
          'Mon, 25 Aug 2014',
          'Thu, 25 Dec 2014',
          'Fri, 26 Dec 2014'
        ].map{ |d| Date.parse(d) }
      )
    end
  end
end