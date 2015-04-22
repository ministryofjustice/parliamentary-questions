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
          PqAssignment.new(last_assignment, (last_assignment - pq_created) * 1.days)
        end

      result_by_bucket(assignments, TimeToAssignBucket.build_from(bucket_dates))
    end

    private

    def pq_data 
      #
      # For each pq find the last created ao_pq and return its created_at date
      # and the pq created_at date
      # Return pq created_at and last ao_pq created_at
      #
      psql = 
        "select " +
        "pq.created_at as pq_created_at, " +
        "max(aopq.created_at) as latest_ao_pq " +
        "from pqs  pq " +
        "inner join action_officers_pqs aopq on (pq.id = aopq.pq_id) " +
        "where pq.created_at is not null " +
        "and aopq.created_at is not null " +
        "and pq.created_at >= '#{bucket_dates.last.strftime('%Y-%m-%d')}'::date " +
        "group by pq.id " +
        "order by pq.id desc;"

      result_set = ActiveRecord::Base.connection.execute(psql).values
      result_set.map{ |t1, t2| [ DateTime.parse(t1), DateTime.parse(t2) ] }
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
