class Report
  class CountCell < ClickableCell
    attr_reader :count

    def self.minister(label, id, state)
      new(label, minister_id: id, state: state)
    end

    def self.press_desk(label, id, state)
      new(label, press_desk_id: id, state: state)
    end

    def initialize(count, filter_params)
      @count = count
      super(count, filter_params)
    end

    def zero?
      @count.zero?
    end
  end
end
