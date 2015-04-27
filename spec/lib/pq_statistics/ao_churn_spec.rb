require 'spec_helper'
require 'business_time'

describe 'PqStatistics::AoChurn' do
  let(:interval) { PqStatistics::BUS_DAY_INTERVAL }
  let(:date)     { Date.today                     }
  
  context '#calculate' do
    before(:each) do
      ao = create(:action_officer) 

      # Create PQs and reassign to different AO on average 2 times for the first date bucket
      pqs = []

      Timecop.freeze(1.business_days.before(date)) do
        pqs = (1..4).to_a.map{ create(:draft_pending_pq) }
      end

      (2..5).each do |n|
        Timecop.freeze(n.business_days.before(date)) do
          pqs.last(2).each { |pq| reallocate_pq(ao, pq) }
        end
      end

      # Create PQs and reassign to different AO on average 1 time for a later date bucket
      pqs = []

      Timecop.freeze(10.business_days.before(date)) do
        pqs = (1..6).to_a.map{ create(:draft_pending_pq) }
      end

      Timecop.freeze(9.business_days.before(date)) do
        pqs.each { |pq| reallocate_pq(ao, pq) }
      end
    end

    it 'should return the number of times a PQ has been allocated to different sets of Action Officers' do
      result = PqStatistics::AoChurn.calculate
          .map{ |obj| [obj.start_date, obj.mean ] }

      expect(result).to eq(
        [
          [ interval.business_days.before(date), 2.0 ],
          [ (2 * interval).business_days.before(date), 0.0 ],
          [ (3 * interval).business_days.before(date), 1.0 ] 
        ] +
        (4..24).map { |i| [ (i * interval).business_days.before(date), 0.0 ] } 
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