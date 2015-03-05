module Validators
  module DateInput
    WINDOW  = 50.years
    MAX_LEN = 50

    def parse_date(date_s)
      @date_class = Date
      secure_parse(date_s)
    end

    def parse_datetime(date_s)
      @date_class = DateTime
      secure_parse(date_s)
    end

    private

    def secure_parse(date_s)
      raise DateTimeInputError unless date_s.size < MAX_LEN
      d = @date_class.parse(date_s)
      raise DateTimeInputError unless d.between?(min_date, max_date)
      d

    rescue ArgumentError
      raise DateTimeInputError
    end

    class DateTimeInputError < StandardError
      def initialize
        super("The date provided was out of the expected range for the application")
      end
    end

    def max_date
      @date_class.current + WINDOW
    end

    def min_date
      @date_class.current - WINDOW
    end
  end
end