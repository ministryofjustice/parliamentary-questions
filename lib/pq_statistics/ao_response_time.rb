module PqStatistics
  module AoResponseTime
    include PqStatistics
    extend  self
    #
    # Calculate the time from PQ commissioned to action officer accept/reject response
    # 
    # Null -> Array[AoResponseTimeBucket]
    #
    def calculate
      responses = 
        pq_data.map do |commissioned, responded|
          PqResponse.new(responded, responded - commissioned)
        end

      result_by_bucket(responses, AoResponseTimeBucket.build_from(bucket_dates))
    end

    private

    def pq_data
      ActionOfficersPq.where('created_at >= ?', bucket_dates.last) 
                      .pluck(:created_at, :updated_at)
    end

    PqResponse = Struct.new(:date, :time_taken)   

    class AoResponseTimeBucket < Bucket
      def update(response)
        @total += response.time_taken
        @count += 1
      end
    end
  end
end
