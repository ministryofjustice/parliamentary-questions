require 'spec_helper'
require 'business_time'

describe 'PqStatistics::AoResponseTime' do
  let(:interval) { PqStatistics::BUS_DAY_INTERVAL }
  let(:date)     { Date.today                     }

  context '#calculate' do
    before(:each) do
      # Create AO_PQs for the latest date bucket with AOs taking an average of 3 days to respond
      Timecop.freeze(1.business_days.before(date)) do
        ao_pqs = (1..4).to_a.map{ create(:accepted_action_officers_pq, pq_id: 1 ) }

        ao_pqs.first(2).each do |ao_pq| 
          ao_pq.update(
            created_at:  6.business_days.before(Date.today) 
          )
        end
      end

      # Create AO_PQs for a later date bucket with AOs taking an average of 1 day to repond
      Timecop.freeze(13.business_days.before(date)) do
        ao_pqs = (1..6).to_a.map{ create(:rejected_action_officers_pq, pq_id: 1) }

        ao_pqs.first(3).each do |ao_pq| 
          ao_pq.update(
            created_at:  Date.today, 
          )
        end
        ao_pqs.last(3).each do |ao_pq| 
          ao_pq.update(
            created_at:  2.business_days.before(Date.today)
          )
        end
      end
    end

    it 'should return the mean time for an AO to respond with accept/reject by date bucket' do
      result = PqStatistics::AoResponseTime.calculate
          .map{ |obj| [obj.start_date, obj.mean ] }

      expect(result).to eq(
        [
          [ interval.business_days.before(date), 108000.0 ],
          [ (2 * interval).business_days.before(date), 0.0 ],
          [ (3 * interval).business_days.before(date), 36000.0 ] 
        ] +
        (4..24).map { |i| [ (i * interval).business_days.before(date), 0 ] } 
      )
    end
  end
end