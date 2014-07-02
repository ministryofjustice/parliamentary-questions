require 'date'
class WorkingDays

  def self.days_after(d,v)
    result = d + v.days
    loop do
      break if !is_weekend(result)
      result += 1
    end
    result
  end
  private def self.is_weekend(value)
    result = false
    result = true if value.saturday? || value.sunday?
    result
  end
end