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
        "select " +
          "agg.pq_id, agg.pq_created_at, sum(agg.num_ao_pqs) " +
        "from ( " +
          "select " +
            "pq.id as pq_id, " +
            "count(*) as num_ao_pqs, " +
            "pq.created_at as pq_created_at, " +
            "date_trunc('minute', aopq.created_at) as aopq_created_at " +
          "from pqs  pq " +
          "inner join action_officers_pqs aopq on (pq.id = aopq.pq_id) " +
          "where pq.created_at is not null " +
          "and aopq.created_at is not null " +
          "and pq.created_at >= '#{bucket_dates.last.strftime('%Y-%m-%d')}'::date " +
          "group by pq.id, pq.created_at, aopq_created_at " +
          "order by pq.id desc " +
        ") as agg " +
        "group by agg.pq_id, agg.pq_created_at;" 

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

