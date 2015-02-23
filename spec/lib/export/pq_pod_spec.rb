require 'spec_helper'

describe Export::PqPod do
  include Unit::QuestionFactory

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

      # Expected inclusions
      mk_pq('uin-z', answer_submitted: nil, date_for_answer: Date.today)
      mk_pq('uin-c', answer_submitted: nil, date_for_answer: Date.yesterday)
      mk_pq('uin-a', answer_submitted: nil, date_for_answer: Date.yesterday - 3)
    end

    it "returns unanswered, and non transfered-out pqs, within the supplied date range" do
      exported_pqs = decode_csv(export.to_csv)

      expect(exported_pqs.count).to eq 3
      expect(exported_pqs.flatten).not_to include 'uin-1'
      expect(exported_pqs.flatten).not_to include 'uin-2'
      expect(exported_pqs.flatten).not_to include 'uin-3'
    end

    it 'returns the results sorted by uin' do
      exported_pqs = decode_csv(export.to_csv)

      expect(exported_pqs.first).to include 'uin-a'
      expect(exported_pqs.last).to include 'uin-z'
    end
  end
end
