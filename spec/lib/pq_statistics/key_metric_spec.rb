require "spec_helper"
require "business_time"

describe "PqStatistics" do
  let(:threshold) { Settings.key_metric_threshold }

  describe "#key_metric_alert" do
    def on_time_percentage(param)
      # Create PQs for the latest date bucket with n% on time
      # n    = (param.round(1) * 10).to_i
      n    = Integer(param.round(1) * 10)
      date = 2.business_days.before(Time.zone.today)
      pqs  = (1..10).to_a.map { create(:answered_pq) }

      pqs.first(n).each do |pq|
        pq.update(
          date_for_answer: 1.business_days.after(date),
          answer_submitted: date,
          state: PqState::ANSWERED,
        )
      end

      pqs.last(10 - n).each do |pq|
        pq.update(
          date_for_answer: 1.business_days.before(date),
          answer_submitted: date,
          state: PqState::ANSWERED,
        )
      end
    end

    it "returns false if the key metric is above the threshold" do
      on_time_percentage(threshold + 0.1)
      expect(PqStatistics.key_metric_alert?).to be false
    end

    it "returns false if there are no pqs in scope the threshold" do
      expect(Pq.all).to be_empty
      expect(PqStatistics.key_metric_alert?).to be false
    end

    it "returns true if the key metric is below the threshold" do
      on_time_percentage(threshold - 0.1)
      expect(PqStatistics.key_metric_alert?).to be true
    end
  end
end
