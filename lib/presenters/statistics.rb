module Presenters
  module Statistics
    class Report
      attr_reader :title, :headers, :rows

      protected

      def initialize(title, headers, rows)
        @headers = headers
        @title   = title
        @rows    = rows
      end

      DataPoint = Struct.new(:start_date, :data, :arrow)

      def self.format(data)
        data[0...-1].map.with_index do |item, i| 
          DataPoint.new(
            *format_item(item, data, i)
          )
        end
      end

      def self.format_item(item, data, i)
        [
          item.start_date.to_s(:date),
          sprintf('%.1f', item.mean / (60 * 60)),
          arrow_for(item.mean - data[i + 1].mean)
        ]        
      end

      def self.arrow_for(n)
        if n > 0
          "↑"
        elsif n < 0
          "↓"
        else 
          "↔"
        end
      end
    end

    class OnTimeReport < Report
      def self.build(data)
        new(
          'PQ Statistics: Answers',
          ['Period start', 'Answered on time', 'Change'],
          format(data)
        )
      end

      private

      def self.format_item(item, data, i)
        [
          item.start_date.to_s(:date),
          sprintf('%.2f%%', item.percentage * 100),
          arrow_for(item.percentage - data[i + 1].percentage)
        ]
      end
    end

    class TimeToAssignReport < Report
      def self.build(data)
        new(
          'PQ Statistics: Assignment',
          ['Period start', 'Hours to assign', 'Change'],
          format(data)
        )
      end
    end

    class AoResponseTimeReport < Report
      def self.build(data)
        new(
          'PQ Statistics: Action Officer response',
          ['Period start', 'Hours to respond', 'Change'],
          format(data)
        )
      end
    end

    class AoChurnReport < Report
      def self.build(data)
        new(
          'PQ Statistics: Action Officer churn',
          ['Period start', 'Reassigned count', 'Change'],
          format(data)
        )
      end

      private

      def self.format_item(item, data, i)
        [
          item.start_date.to_s(:date),
          sprintf('%.2f', item.mean),
          arrow_for(item.mean - data[i + 1].mean)
        ]
      end
    end
  end
end


