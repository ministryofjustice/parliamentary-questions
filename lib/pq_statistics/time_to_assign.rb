module PqStatistics
  module TimeToAssign
    include PqStatistics
    extend  self
    #
    # Calculate length of time between PQ created (i.e import time) and the 
    # last action officer assigned
    # 
    # Null -> Array[TimeToAssignBucket]
    #
    def calculate
      assignments = 
        pq_data.map do |pq_created, last_assignment| 
          PqAssignment.new(
            last_assignment, 
            delta_t(pq_created, last_assignment)
          )
        end       

      result_by_bucket(assignments, TimeToAssignBucket.build_from(bucket_dates))
    end

    private

    def pq_data 
      #
      # For each pq (excluding IWWs) find the last created ao_pq 
      # Return last ao_pq created_at date and the pq created_at date
      #
      psql = 
        "SELECT " +
        "pq.created_at as pq_created_at, " +
        "max(aopq.created_at) as latest_ao_pq " +
        "FROM pqs  pq " +
        "INNER JOIN action_officers_pqs aopq on (pq.id = aopq.pq_id) " +
        "WHERE pq.created_at is NOT NULL " +
        "AND aopq.created_at is NOT NULL " +
        "AND pq.created_at >= '#{bucket_dates.last.strftime('%Y-%m-%d')}'::date " +
        "AND pq.follow_up_to is NULL " +
        "GROUP BY pq.id " +
        "ORDER BY pq.id desc;"

      result_set = ActiveRecord::Base.connection.execute(psql).values
      result_set.map{ |t1, t2| [ Time.parse(t1), Time.parse(t2) ] }
    end

    PqAssignment = Struct.new(:date, :time_taken)

    class TimeToAssignBucket < Bucket
      def update(assignment)
        @total += assignment.time_taken
        @count += 1
      end
    end
  end
end
