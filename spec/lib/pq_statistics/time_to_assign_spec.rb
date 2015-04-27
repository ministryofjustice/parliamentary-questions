require 'spec_helper'
require 'business_time'

describe 'PqStatistics::TimeToAssign' do
  let(:interval) { PqStatistics::BUS_DAY_INTERVAL }
  let(:date)     { Date.today                     }

  context '#calculate' do
    before(:each) do
      # Create PQs for the latest date bucket taking an average of 1 day to assign
      Timecop.freeze(1.business_days.before(date)) do
        pqs = (1..4).to_a.map{ create(:not_responded_pq) }

        pqs.first(2).each do |pq| 
          pq.update(
            created_at:  2.business_days.before(Date.today), 
          )
        end
      end

      # Create PQs for a later date bucket taking an average of 1.5 days to assign
      Timecop.freeze(12.business_days.before(date)) do
        pqs = (1..4).to_a.map{ create(:not_responded_pq) }

        pqs.first(2).each do |pq| 
          pq.update(
            created_at:  1.business_days.before(Date.today), 
          )
        end
        pqs.last(2).each do |pq| 
          pq.update(
            created_at:  2.business_days.before(Date.today), 
          )
        end
      end
    end

    it 'should return the mean time to assignment for PQs by date bucket' do
      result = PqStatistics::TimeToAssign.calculate
          .map{ |obj| [obj.start_date, obj.mean ] }

      expect(result).to eq(
        [
          [ interval.business_days.before(date), 36000.0 ],
          [ (2 * interval).business_days.before(date), 0.0 ],
          [ (3 * interval).business_days.before(date), 54000.0 ] 
        ] +
        (4..24).map { |i| [ (i * interval).business_days.before(date), 0.0 ] } 
      )
    end
  end
end