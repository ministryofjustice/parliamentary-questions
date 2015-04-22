require 'spec_helper'

describe 'PqStatistics::AoResponseTime' do
  context '#calculate' do
    before(:each) do
      # Create AO_PQs for the latest date bucket with AOs taking an average of 3 days to respond
      Timecop.freeze(Date.yesterday) do
        ao_pqs = (1..4).to_a.map{ create(:accepted_action_officers_pq, pq_id: 1 ) }

        ao_pqs.first(2).each do |ao_pq| 
          ao_pq.update(
            created_at:  Date.today - 6.days, 
          )
        end
      end

      # Create AO_PQs for a later date bucket with AOs taking an average of 1 day to repond
      Timecop.freeze(Date.yesterday - 15.days) do
        ao_pqs = (1..6).to_a.map{ create(:rejected_action_officers_pq, pq_id: 1) }

        ao_pqs.first(3).each do |ao_pq| 
          ao_pq.update(
            created_at:  Date.today, 
          )
        end
        ao_pqs.last(3).each do |ao_pq| 
          ao_pq.update(
            created_at:  Date.today - 2.days, 
          )
        end
      end
    end

    it 'should return the mean time for an AO to respond with accept/reject by date bucket' do
      result = PqStatistics::AoResponseTime.calculate
          .map{ |obj| [obj.start_date, obj.mean ] }

      expect(result).to eq(
        [
          [ Date.today - 7.days , 259200.0],
          [ Date.today - 14.days, 0.0 ],
          [ Date.today - 21.days , 86400.0 ] 
        ] +
        (4..24).map { |i| [ Date.today - (i * 7).days, 0 ] } 
      )
    end
  end
end