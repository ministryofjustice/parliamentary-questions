require "business_time"
#
# Calculates statistics for MI reporting
#
module PqStatistics
  extend self
  #
  # Define bucket intervals and quantity
  #
  BUS_DAY_INTERVAL = 5
  WINDOW           = 24 * BUS_DAY_INTERVAL

  def key_metric_alert?
    value  = key_metric.percentage
    sample = key_metric.count

    sample != 0 && value < Settings.key_metric_threshold
  end

private

  def key_metric
    PercentOnTime.calculate_from(bucket_dates.first)
  end

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

  def delta_t(time1, time2)
    Time
      .first_business_day(time1)
      .business_time_until(time2)
      .to_f
  end

  def bucket_dates
    @bucket_dates ||=
      (BUS_DAY_INTERVAL..WINDOW)
      .step(BUS_DAY_INTERVAL)
      .map { |i| i.business_days.before(bucket_date0) }
  end

  def bucket_date0
    @bucket_date0 ||= Time.zone.today
  end

  def result_by_bucket(events, buckets)
    events.each_with_object(buckets) do |event, result|
      upper_bound = bucket_date0

      result.each do |bucket|
        if event.date <= upper_bound && event.date > bucket.start_date
          bucket.update(event)
          break
        end
        upper_bound = bucket.start_date
      end
    end
  end
end
