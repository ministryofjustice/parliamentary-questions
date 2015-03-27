class Report
  class Row
    attr_reader :label, :cells

    def initialize(label, cells)
      @label = label
      @cells = cells
    end
  end
end
