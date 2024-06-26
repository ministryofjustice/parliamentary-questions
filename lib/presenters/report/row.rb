module Presenters
  class Report
    class Row
      attr_reader :cells, :state

      def initialize(state, cells)
        @state = state
        @cells = cells
      end

      def label
        PqState.state_label(@state)
      end
    end
  end
end
