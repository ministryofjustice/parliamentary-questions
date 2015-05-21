require 'spec_helper'
require 'business_time'

describe 'PqStatistics' do
  let(:threshold) { Settings.key_metric_threshold }

  context '#key_metric_alert' do
    def set_on_time_percentage(n)
      # Create PQs for the latest date bucket with n% on time
      n    = (n.round(1) * 10).to_i
      date = 2.business_days.before(Date.today)
      pqs  = (1..10).to_a.map{ create(:answered_pq) }

      pqs.first(n).each do |pq| 
        pq.update(
          date_for_answer:  1.business_days.after(date), 
          answer_submitted: date,
          state:            PQState::ANSWERED
        )
      end

      pqs.last(10 - n).each do |pq| 
        pq.update(
          date_for_answer:  1.business_days.before(date), 
          answer_submitted: date,
          state:            PQState::ANSWERED
        )
      end
    end

    it 'should return false if the key metric is above the threshold' do
      set_on_time_percentage(threshold + 0.1)

      expect(PqStatistics.key_metric_alert?).to be false
    end

    it 'should return false if there are no pqs in scope the threshold' do
      expect(Pq.all).to be_empty
      expect(PqStatistics.key_metric_alert?).to be false
    end

    it 'should return true if the key metric is below the threshold' do
      set_on_time_percentage(threshold - 0.1)

      expect(PqStatistics.key_metric_alert?).to be true
    end
  end
end