module PqStatistics
  module AoChurn
    include PqStatistics
    extend  self
    #
    # Calculate the average number of times a PQ is recommissioned or
    # allocated to different AOs
    # 
    # Null -> Array[AoChurnBucket]
    #
    def calculate
      assignments = 
        pq_data.map do |assign_date, ao_cycles|
          PqAssignment.new(assign_date, ao_cycles)
        end

      result_by_bucket(assignments, AoChurnBucket.build_from(bucket_dates))
    end

    private

    def pq_data
      #
      # For each pq, count the number of groups of ao_pqs.
      # All ao_pqs created within the same minute count as one group
      # Return pq id, pq created_at and count of ao_pq groups
      #
      psql = 
        "SELECT " +
          "agg.pq_id, agg.pq_created_at, sum(agg.num_ao_pqs) " +
        "FROM ( " +
          "SELECT " +
            "pq.id as pq_id, " +
            "COUNT(*) as num_ao_pqs, " +
            "pq.created_at as pq_created_at, " +
            "DATE_TRUNC('minute', aopq.created_at) as aopq_created_at " +
          "FROM pqs  pq " +
          "INNER JOIN action_officers_pqs aopq on (pq.id = aopq.pq_id) " +
          "WHERE pq.created_at is NOT NULL " +
          "AND aopq.created_at is NOT NULL " +
          "AND pq.created_at >= '#{bucket_dates.last.strftime('%Y-%m-%d')}'::date " +
          "GROUP BY pq.id, pq.created_at, aopq_created_at " +
          "ORDER BY pq.id desc " +
        ") AS agg " +
        "GROUP BY agg.pq_id, agg.pq_created_at;" 

      result_set = ActiveRecord::Base.connection.execute(psql).values
      result_set.map{ |_, date, count| [ DateTime.parse(date), count.to_i - 1 ] }
    end

    PqAssignment = Struct.new(:date, :ao_cycles)   

    class AoChurnBucket < Bucket
      def update(assignment)
        @total += assignment.ao_cycles
        @count += 1
      end  
    end
  end
end

