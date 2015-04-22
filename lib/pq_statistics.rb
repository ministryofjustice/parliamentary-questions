module PqStatistics
  #
  # Calculates statistics for MI reporting
  #
  DATE_INTERVAL = 7
  WINDOW        = 24 * DATE_INTERVAL

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

  def bucket_dates
    @bucket_dates ||= 
      (DATE_INTERVAL..WINDOW)
        .step(DATE_INTERVAL)
        .map{ |i| bucket_date_0 - i.days }
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

