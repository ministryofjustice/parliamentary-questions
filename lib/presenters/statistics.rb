module Presenters
  # Here the statistics
  module Statistics
  module_function

    Link = Struct.new(:name, :path, :description)

    def report_links
      [
        Link.new("Stages Time",
                 "/stages_time",
                 "Average time taken to complete each stage of the PQ process"),
        Link.new("On Time",
                 "/on_time",
                 "Percentage of questions on answered time"),
        Link.new("Time to Assign",
                 "/time_to_assign",
                 "Average time to assign a question to an Action Officer"),
        Link.new("AO Response Time",
                 "/ao_response_time",
                 "Average time for an Action Officer to respond with accept/reject"),
        Link.new("AO Churn",
                 "/ao_churn",
                 "Average number of times a different set of Action Officers are assigned"),
      ]
    end

    class Report
      # Comment for rubocop
      attr_reader :title, :headers, :rows

      def self.format(data)
        data[0...-1].map.with_index do |item, index|
          DataPoint.new(
            *format_item(item, data, index),
          )
        end
      end

      private_class_method :format

      def self.format_item(item, data, index)
        [
          item.start_date.to_formatted_s(:date),
          sprintf("%.1f", item.mean / (60 * 60)),
          arrow_for(item.mean - data[index + 1].mean),
        ]
      end

      private_class_method :format_item

      def self.arrow_for(number)
        if number.positive?
          "↑"
        elsif number.negative?
          "↓"
        else
          "↔"
        end
      end

      private_class_method :arrow_for

    protected

      def initialize(title, headers, rows)
        @headers = headers
        @title   = title
        @rows    = rows
      end

      DataPoint = Struct.new(:start_date, :data, :arrow)
    end

    class OnTimeReport < Report
      def self.build(data)
        new(
          "PQ Statistics: Answers",
          ["Period start", "Answered on time", "Change"],
          format(data),
        )
      end

      # private

      def self.format_item(item, data, index)
        [
          item.start_date.to_formatted_s(:date),
          sprintf("%.2f%%", item.percentage * 100),
          arrow_for(item.percentage - data[index + 1].percentage),
        ]
      end
    end

    class TimeToAssignReport < Report
      def self.build(data)
        new(
          "PQ Statistics: Assignment",
          ["Period start", "Hours to assign", "Change"],
          format(data),
        )
      end
    end

    class AoResponseTimeReport < Report
      def self.build(data)
        new(
          "PQ Statistics: Action Officer response",
          ["Period start", "Hours to respond", "Change"],
          format(data),
        )
      end
    end

    class AoChurnReport < Report
      def self.build(data)
        new(
          "PQ Statistics: Action Officer churn",
          ["Period start", "Reassigned count", "Change"],
          format(data),
        )
      end

      # private

      def self.format_item(item, data, index)
        [
          item.start_date.to_formatted_s(:date),
          sprintf("%.2f", item.mean),
          arrow_for(item.mean - data[index + 1].mean),
        ]
      end
    end

    class StagesTimeReport
      def self.build(data)
        new(
          "PQ Statistics: stages time",
          data.first,
          data.last,
        )
      end

    private

      def initialize(title, current_journey, benchmark_journey)
        @title             = title
        @current_journey   = summarize(current_journey)
        @benchmark_journey = summarize(benchmark_journey)
      end

      def summarize(journey)
        journey.stages.map { |stage| StageSummary.new(stage) }
      end

      class StageSummary
        attr_reader :name, :time

        def initialize(stage)
          @name = stage.name
          @time = sprintf("%.1f", stage.average_time / (60 * 60))
        end
      end
    end
  end
end
