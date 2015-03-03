module Validators
  module DateInput

    WINDOW  = 100.years
    MAX_LEN = 100

    def secure_parse(date_s)
      raise DateTimeInputError unless date_s.size < MAX_LEN
      d = DateTime.parse(date_s)
      raise DateTimeInputError unless d.between?(min_date, max_date)
      d

    rescue ArgumentError
      raise DateTimeInputError
    end

    private

    class DateTimeInputError < StandardError
      def initialize
        super("The date provided was out of the expected range for the application")
      end
    end

    def max_date
      DateTime.now + WINDOW
    end

    def min_date
      DateTime.now - WINDOW
    end
  end
end