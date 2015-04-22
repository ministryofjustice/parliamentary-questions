require 'spec_helper'

describe 'PqStatistics::AoChurn' do
  context '#calculate' do
    before(:each) do
      ao = create(:action_officer) 

      # Create PQs and reassign to different AO on average 2 times for the first date bucket
      pqs = []

      Timecop.freeze(Date.yesterday) do
        pqs = (1..4).to_a.map{ create(:draft_pending_pq) }
      end

      (1..4).each do |n|
        Timecop.freeze(Date.yesterday - n.days) do
          pqs.last(2).each { |pq| reallocate_pq(ao, pq) }
        end
      end

      # Create PQs and reassign to different AO on average 1 time for a later date bucket
      pqs = []

      Timecop.freeze(Date.yesterday - 15.days) do
        pqs = (1..6).to_a.map{ create(:draft_pending_pq) }
      end

      Timecop.freeze(Date.yesterday - 14.days) do
        pqs.each { |pq| reallocate_pq(ao, pq) }
      end
    end

    it 'should return the number of times a PQ has been allocated to different sets of Action Officers' do
      result = PqStatistics::AoChurn.calculate
          .map{ |obj| [obj.start_date, obj.mean ] }

      expect(result).to eq(
        [
          [ Date.today - 7.days , 2.0 ],
          [ Date.today - 14.days, 0.0 ],
          [ Date.today - 21.days , 1.0 ] 
        ] +
        (4..24).map { |i| [ Date.today - (i * 7).days, 0 ] } 
      )
    end

    def reallocate_pq(ao, pq)
      ao_pq =  ActionOfficersPq.create!(
                pq_id: pq.id,
                action_officer_id: ao.id
              )
      pq.action_officers_pqs << ao_pq
    end
  end
end