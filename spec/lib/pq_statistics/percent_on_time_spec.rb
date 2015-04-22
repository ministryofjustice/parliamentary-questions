require 'spec_helper'

describe 'PqStatistics::PercentOnTime' do
  context '#calculate' do
    before(:each) do
      # Create PQs for the latest date bucket with 50% on time
      pqs = (1..4).to_a.map{ create(:answered_pq) }

      pqs.first(2).each do |pq| 
        pq.update(
          date_for_answer:  Date.tomorrow, 
          answer_submitted: Date.today,
          state:            PQState::ANSWERED
        )
      end
      pqs.last(2).each do |pq| 
        pq.update(
          date_for_answer:  Date.yesterday, 
          answer_submitted: Date.today,
          state:            PQState::ANSWERED
        )
      end

      # Create PQs for a past date bucket with 25% on time
      old_pqs = (1..4).to_a.map{ create(:answered_pq) }
      
      old_pqs.first.update(
        date_for_answer:  Date.tomorrow - 15.days, 
        answer_submitted: Date.today - 15.days,
        state:            PQState::ANSWERED
      )

      old_pqs.last(3).each do |pq| 
        pq.update(
          date_for_answer:  Date.yesterday - 15.days, 
          answer_submitted: Date.today - 15.days,
          state:            PQState::ANSWERED
        )
      end
    end

    it 'should return the percentage of PQs answered on time for each date bucket' do
      result = PqStatistics::PercentOnTime.calculate
                .map{ |obj| [obj.start_date, obj.percentage] }

      expect(result).to eq(
        [
          [ Date.today - 7.days , 0.5 ],
          [ Date.today - 14.days, 0.0 ],
          [ Date.today - 21.days , 0.25 ] 
        ] +
        (4..24).map { |i| [ Date.today - (i * 7).days, 0 ] } 
      )
    end
  end
end