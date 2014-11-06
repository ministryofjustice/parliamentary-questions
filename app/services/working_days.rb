require 'date'

class WorkingDays
  def self.days_after(d, v)
    result = d + v.days
    loop do
      break unless weekend?(result)
      result += 1
    end
    result
  end

private

  def self.weekend?(day)
    day.saturday? || day.sunday?
  end
end
