module PqStatistics
  module StagesTime
    extend  self

    def calculate
      pq_data.reduce(Journey.new) do |journey, pq|
        journey.update(pq)
      end 
    end

    def pq_data
      Pq.answered
        .where.not(answer_submitted: nil, date_for_answer: nil)
        .where('created_at >= ?', bucket_dates.last) 
    end
  end
end