module PqStatistics
  module PercentOnTime
    include PqStatistics
    extend  self
    #
    # Calculate % of PQs answered on time
    # 
    # Null -> Array[OnTimeBucket]
    #
    #
    def calculate
      calculate_for_dates(bucket_dates)
    end
    #
    # Calculate the metric for a single date bucket for metrics dashboard
    #
    # Null -> OnTimeBucket
    #
    def calculate_from(date)
      calculate_for_dates([date]).first
    end

    private

    def calculate_for_dates(dates)
      submissions = 
        pq_data(dates).map do |submitted, deadline|
          PqSubmission.new(submitted, (submitted <= deadline.to_datetime.end_of_day))
        end

      result_by_bucket(submissions, OnTimeBucket.build_from(dates))
    end

    def pq_data(dates)
      Pq.answered
        .where.not(answer_submitted: nil, date_for_answer: nil)
        .where('answer_submitted > ?', dates.last)
        .pluck(:answer_submitted, :date_for_answer)
    end

    PqSubmission = Struct.new(:date, :on_time?)   

    class OnTimeBucket < Bucket
      def update(submission)
        @count += 1
        @total += 1 if submission.on_time?
      end
    end
  end
end
