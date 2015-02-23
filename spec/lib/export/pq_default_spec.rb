require 'spec_helper'

describe Export::PqDefault do
  include Unit::QuestionFactory

  let(:export) {
    Export::PqDefault.new(Date.yesterday, Date.today)
  }

  context "when no records are present" do
    it "returns a blank CSV" do
      expect(decode_csv(export.to_csv)).to eq []
    end
  end

  context "when some records are present" do
    before(:each) do
      # Expected exclusions
      mk_pq('uin-1', answer_submitted: Date.today - 5)
      mk_pq('uin-2', tabled_date: Date.today + 1)
      mk_pq('uin-3', transfer_out_ogd_id: 1)

      # Expected inclusions
      mk_pq('uin-z')
      mk_pq('uin-a')
      mk_pq('uin-c')
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
