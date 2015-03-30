class Report
  class ClickableCell
    include Rails.application.routes.url_helpers

    def self.minister(label, id)
      new(label, minister_id: id)
    end

    def self.press_desk(label, id)
      new(label, press_desk_id: id)
    end

    attr_reader :label

    def initialize(label, filter_params)
      @label         = label
      @filter_params = filter_params
    end

    def path
      filter_all_path(@filter_params)
    end
  end
end
