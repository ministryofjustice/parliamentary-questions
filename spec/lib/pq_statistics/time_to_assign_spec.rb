require 'spec_helper'

describe 'PqStatistics::TimeToAssign' do
  context '#calculate' do
    before(:each) do
      # Create PQs for the latest date bucket taking an average of 1 day to assign
      Timecop.freeze(Date.yesterday) do
        pqs = (1..4).to_a.map{ create(:not_responded_pq) }

        pqs.first(2).each do |pq| 
          pq.update(
            created_at:  Date.today - 2.days, 
          )
        end
      end

      # Create PQs for a later date bucket taking an average of 1.5 days to assign
      Timecop.freeze(Date.yesterday - 15.days) do
        pqs = (1..4).to_a.map{ create(:not_responded_pq) }

        pqs.first(2).each do |pq| 
          pq.update(
            created_at:  Date.today - 1.days, 
          )
        end
        pqs.last(2).each do |pq| 
          pq.update(
            created_at:  Date.today - 2.days, 
          )
        end
      end
    end

    it 'should return the mean time to assignment for PQs by date bucket' do
      result = PqStatistics::TimeToAssign.calculate
          .map{ |obj| [obj.start_date, obj.mean ] }

      expect(result).to eq(
        [
          [ Date.today - 7.days , 86400.0 ],
          [ Date.today - 14.days, 0.0 ],
          [ Date.today - 21.days , 129600.0 ] 
        ] +
        (4..24).map { |i| [ Date.today - (i * 7).days, 0 ] } 
      )
    end
  end
end