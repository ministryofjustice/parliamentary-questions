require "rails_helper"

describe Export::PqSelection do
  include Unit::QuestionFactory
  include CSVHelpers

  let(:export) { described_class.new(Date.yesterday - 2.days, Time.zone.today, "uin-1,uin-3") }

  context "when no records are present" do
    it "returns a blank CSV" do
      expect(decode_csv(export.to_csv)).to eq []
    end
  end

  context "when some records are present" do
    before do
      # Expected result
      mk_pq("uin-1", answer_submitted: nil, date_for_answer: Date.yesterday - 3)
      mk_pq("uin-2", tabled_date: Time.zone.today - 5)
      # Expected result
      mk_pq("uin-3", answer_submitted: Time.zone.today, date_for_answer: Date.yesterday)
      mk_pq("uin-4", pod_clearance: Time.zone.today)
      mk_pq("uin-z", answer_submitted: nil, date_for_answer: Time.zone.today)
      mk_pq("uin-c", answer_submitted: nil, date_for_answer: Date.yesterday)
      mk_pq("uin-a", answer_submitted: nil, date_for_answer: Date.yesterday - 3)
    end

    it "returns specified questions" do
      exported_pqs =
        decode_csv(export.to_csv).map do |h|
          [
            h["PIN"],
            h["Full_PQ_subject"],
            h["Date First Appeared in Parliament"],
            h["Date Due in Parliament"],
          ]
        end

      expect(exported_pqs).to eq(
        [
          ["uin-1", "uin-1 body text", date_s(Date.yesterday), date_s(Date.yesterday - 3)],
          ["uin-3", "uin-3 body text", date_s(Date.yesterday), date_s(Date.yesterday)],
        ],
      )
    end
  end
end
