  require 'holiday_calendar'

  module BusinessTimeHelpers
    extend self

    def load_holidays
      holidays = list_holidays(years_to_load)

      convert_to_dates(holidays)
    end

    def years_to_load
      (((Date.today - PqStatistics::WINDOW.days).year - 1)..(Date.today.year + 1)).to_a
    end

    def calendar
      HolidayCalendar.load(:uk)
    end

    private

    def list_holidays(years)
      years
        .reduce([]) { |hols, y| hols << calendar.list_for_year(y) }
        .flatten
    end

    def convert_to_dates(holidays)
      holidays.map { |holiday_s| Date.parse(holiday_s) } 
    end
  end
  
  # Configure BusinessTime options
  BusinessTime::Config do
    # Define work day start/end times
    beginning_of_workday = '8:00 am'
    end_of_workday       = '6:00 pm'

    # Define UK public holidays
    holidays = BusinessTimeHelpers.load_holidays  
  end