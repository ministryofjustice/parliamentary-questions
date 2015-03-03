module Validators
  module DateInput

    WINDOW  = 100.years
    MAX_LEN = 100

    def secure_parse(input_d)
      input_d  = input_d.to_s
      d        = DateTime.parse(input_d)
      
      unless d.between?(min_date, max_date) && input_d.size < MAX_LEN
        raise DateTimeInputError
      end
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