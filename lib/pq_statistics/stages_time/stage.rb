module PqStatistics
  module StagesTime
    class Stage
      include PqStatistics

      attr_reader :name

      def average_time
        @duration / (@count.nonzero? || 1)
      end

      def update(pq)
        #
        # Updates duration of a stage from pq
        # Pq -> Stage
        #
        raise NotImplementedError, 'The #update method should be implemented by subclasses'
      end

      protected

      def initialize(name)
        @name     = name
        @duration = 0.0
        @count    = 0
      end

      def increment(start_time, end_time)
        @duration += delta_t(start_time.to_time, end_time.to_time)
        @count    += 1
      end

      def cleared_by_minister(pq)
        if pq.policy_minister
          [pq.cleared_by_answering_minister, pq.cleared_by_policy_minister].max
        else
          pq.cleared_by_answering_minister
        end
      end
    end

    class DraftAnswer < Stage
      def initialize
        super('Draft Answer')
      end

      def update(pq)
        increment(pq.created_at, pq.draft_answer_received)
        self
      end
    end

    class PodClearance < Stage
      def initialize
        super('POD Clearance')
      end

      def update(pq)
        increment(pq.draft_answer_received, pq.pod_clearance)
        self
      end
    end

    class MinisterClearance < Stage
      def initialize
        super('Minister Clearance')
      end

      def update(pq)
        increment(pq.pod_clearance, cleared_by_minister(pq))
        self
      end
    end

    class SubmitAnswer < Stage
      def initialize
        super('Submit Answer')
      end

      def update(pq)
        increment(cleared_by_minister(pq), pq.answer_submitted)
        self
      end
    end
  end
end
