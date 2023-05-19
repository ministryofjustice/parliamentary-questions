require 'date'

module WorkingDays
  extend self

  def days_after(d, v)
    result = d + v.days
    loop do
      break unless weekend?(result)

      result += 1
    end
    result
  end

  # private

  def weekend?(day)
    day.saturday? || day.sunday?
  end
end
