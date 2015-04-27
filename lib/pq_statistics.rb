require 'business_time'
#
# Calculates statistics for MI reporting
#
module PqStatistics
  #
  # Define bucket intervals and quantity
  #
  BUS_DAY_INTERVAL = 5
  WINDOW           = 24 * BUS_DAY_INTERVAL

  private

  class Bucket
    attr_accessor :start_date, :count, :total

    def self.build_from(dates)
      dates.map { |date| new(date, 0, 0) } 
    end

    def percentage
      total.to_f / (count.nonzero? || 1)
    end

    alias_method :mean, :percentage

    private

    def initialize(start_date, count, total)
      @start_date = start_date
      @count      = count
      @total      = total
    end
  end

  def delta_t(time_1, time_2)
    Time
      .first_business_day(time_1)
      .business_time_until(time_2)
      .to_f
  end

  def bucket_dates
    @bucket_dates ||= 
      (BUS_DAY_INTERVAL..WINDOW)
        .step(BUS_DAY_INTERVAL)
        .map{ |i| i.business_days.before(bucket_date_0) }
  end

  def bucket_date_0
    @bucket_date_0 ||= Date.today
  end

  def result_by_bucket(events, buckets)
    events.reduce(buckets) do |result, event|

      upper_bound = bucket_date_0

      result.each do |bucket|
        if event.date <= upper_bound && event.date > bucket.start_date
          bucket.update(event)
          break
        end
        upper_bound = bucket.start_date 
      end
      
      result
    end
  end
end

