require_relative 'stage'

module PqStatistics
  module StagesTime

    class Journey
      STAGES = 
      [
        DraftAnswer,
        PodClearance,
        MinisterClearance,
        SubmitAnswer,
      ]

      def initialize
        @stages = STAGES.map(&:new)
      end

      def update(pq)
        @stages.each { |stage| stage.update(pq) }
        self
      end
    end
  end
end