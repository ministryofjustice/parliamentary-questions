require 'spec_helper'
require 'business_time'

describe 'PqStatistics::PercentOnTime' do
  let(:interval) { PqStatistics::BUS_DAY_INTERVAL }
  let(:date)     { Date.today                     }

  context '#calculate' do
    before(:each) do
      # Create PQs for the latest date bucket with 50% on time
      pqs = (1..4).to_a.map{ create(:answered_pq) }

      pqs.first(2).each do |pq| 
        pq.update(
          date_for_answer:  10.business_days.after(date), 
          answer_submitted: date,
          state:            PQState::ANSWERED
        )
      end
      pqs.last(2).each do |pq| 
        pq.update(
          date_for_answer:  1.business_days.before(date), 
          answer_submitted: date,
          state:            PQState::ANSWERED
        )
      end

      # Create PQs for a past date bucket with 25% on time
      old_pqs = (1..4).to_a.map{ create(:answered_pq) }
      
      old_pqs.first.update(
        date_for_answer:  9.business_days.before(date), 
        answer_submitted: 10.business_days.before(date),
        state:            PQState::ANSWERED
      )

      old_pqs.last(3).each do |pq| 
        pq.update(
          date_for_answer:  11.business_days.before(date), 
          answer_submitted: 10.business_days.before(date),
          state:            PQState::ANSWERED
        )
      end
    end

    it 'should return the percentage of PQs answered on time for each date bucket' do
      result = PqStatistics::PercentOnTime.calculate
                .map{ |obj| [obj.start_date, obj.percentage] }

      expect(result).to eq(
        [
          [ interval.business_days.before(date) , 0.5 ],
          [ (2 * interval).business_days.before(date), 0.0 ],
          [ (3 * interval).business_days.before(date) , 0.25 ] 
        ] +
        (4..24).map { |i| [ (i * interval).business_days.before(date), 0.0 ] } 
      )
    end
  end
end