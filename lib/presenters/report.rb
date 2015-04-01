module Presenters
  class Report
    attr_reader :header_cells, :rows, :title

    def initialize(header_cells, rows, title)
      @header_cells = header_cells
      @rows         = rows
      @title        = title
    end

    def self.ministers(report_h, ministers)
      build(report_h, ministers, PQState::IN_PROGRESS, 'Minister report')
    end

    def self.press_desk(report_h, press_desks)
      states = PQState::IN_PROGRESS + PQState::CLOSED
      build(report_h, press_desks, states, 'Press desk report')
    end

    private_class_method

    def self.build(report_h, records, states, title)
      header_cells = records.map { |r| present_cell(r) }
      rows         = states.map do |state|
        counts = report_h.fetch(state, {})
        cells  = records.map do |r|
          count = counts.fetch(r.id, 0)
          present_count_cell(count, r, state)
        end
        Row.new(state, cells)
      end

      new(header_cells, rows, title)
    end

    def self.present_cell(r)
      case r
      when Minister
        ClickableCell.minister(r.name, r.id)
      when PressDesk
        ClickableCell.press_desk(r.name, r.id)
      else
        raise ArgumentError, "record should be a Minister or a PressDesk"
      end
    end

    def self.present_count_cell(count, r, state)
      case r
      when Minister
        CountCell.minister(count, r.id, state)
      when PressDesk
        CountCell.press_desk(count, r.id, state)
      else
        raise ArgumentError, "record should be a Minister or a PressDesk"
      end
    end
  end
end
