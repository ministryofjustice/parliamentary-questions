require 'business_time'

module PqStatistics
  module StagesTime
    extend  self

    def calculate
      [ calculate_5_day, calculate_30_day ]
    end

    def calculate_5_day
      calculate_n_day(5)
    end

    def calculate_30_day
      calculate_n_day(30)
    end

    private

    def calculate_n_day(window)
      pq_data(window).reduce(Journey.new) do |journey, pq|
        journey.update(pq)
      end 
    end

    def pq_data(window)
      Pq.answered
        .where('created_at >= ?', window.business_days.before(Date.today)) 
    end
  end
end