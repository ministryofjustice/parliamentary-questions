module PqStatistics
  module PercentOnTime
    include PqStatistics
    extend  self
    #
    # Calculate % of PQs answered on time
    # 
    # Null -> Array[OnTimeBucket]
    #
    def calculate
      submissions = 
        pq_data.map do |submitted, deadline|
          PqSubmission.new(submitted, (submitted <= deadline.to_datetime.end_of_day))
        end

      result_by_bucket(submissions, OnTimeBucket.build_from(bucket_dates))
    end

    private

    def pq_data
      Pq.answered
        .where.not(answer_submitted: nil, date_for_answer: nil)
        .where('answer_submitted > ?', bucket_dates.last)
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
