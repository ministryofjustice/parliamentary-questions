  require 'holiday_calendar'

  module BusinessTimeHelpers
    extend self

    def holidays
      scope
        .to_a
        .reduce([]) { |hols, y| hols << calendar.list_for_year(y) }
        .flatten
        .map { |h| Date.parse(h) } 
    end

    def scope
      (((Date.today - PqStatistics::WINDOW.days).year - 1)..(Date.today.year + 1))
    end

    def calendar
      HolidayCalendar.load(:uk)
    end
  end

  # Define work day start/end times
  BusinessTime::Config.beginning_of_workday = '8:00 am'
  BusinessTime::Config.end_of_workday       = '6:00 pm'

  # Define UK public holidays
  BusinessTime::Config.holidays             = BusinessTimeHelpers.holidays  