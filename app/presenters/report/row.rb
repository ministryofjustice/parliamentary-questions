class Report
  class Row
    attr_reader :cells, :state

    def initialize(state, cells)
      @state = state
      @cells = cells
    end

    def label
      PQState.state_label(@state)
    end
  end
end
