require 'spec_helper'

describe Export::PqPod do
  include Unit::QuestionFactory
  include CSVHelpers

  let(:export) {
    Export::PqPod.new(Date.yesterday - 2.days, Date.today)
  }

  context "when no records are present" do
    it "returns a blank CSV" do
      expect(decode_csv(export.to_csv)).to eq []
    end
  end

  context "when some records are present" do
    before(:each) do
      # Expected exclusions
      mk_pq('uin-1', tabled_date: Date.today + 5)
      mk_pq('uin-2', tabled_date: Date.today - 5)
      mk_pq('uin-3', answer_submitted: Date.today)
      mk_pq('uin-4', pod_clearance: Date.today)

      # Expected inclusions
      mk_pq('uin-z', answer_submitted: nil, date_for_answer: Date.today)
      mk_pq('uin-c', answer_submitted: nil, date_for_answer: Date.yesterday)
      mk_pq('uin-a', answer_submitted: nil, date_for_answer: Date.yesterday - 3)
    end

    it "returns unanswered, and non transfered-out pqs, within the supplied date range ordered by date for answer" do
      exported_pqs = decode_csv(export.to_csv).map do |h|
        [
          h['PIN'],
          h['Full_PQ_subject'],
          h['Date First Appeared in Parliament'],
          h['Date Due in Parliament'],
        ]
      end

      expect(exported_pqs).to eq([
        ['uin-a', 'uin-a body text', datetime_s(Date.yesterday), date_s(Date.yesterday - 3)],
        ['uin-c', 'uin-c body text', datetime_s(Date.yesterday), date_s(Date.yesterday)],
        ['uin-z', 'uin-z body text', datetime_s(Date.yesterday), date_s(Date.today)]
      ])
    end
  end
end
