require 'spec_helper'

describe Export::PqDefault do
  def decode_csv(s)
    CSV.parse(s).drop(1)
  end

  def mk_pq(uin, h)
    default_h = {
      uin: uin,
      raising_member_id: 1,
      question: 'test question',
      tabled_date: Date.yesterday,
      answer_submitted: Date.today,
    }

    Pq.create(default_h.merge(h))
  end

  let(:export) {
    Export::PqDefault.new(Date.yesterday, Date.today)
  }

  context "when no records are present" do
    it "returns a blank CSV" do
      expect(decode_csv(export.to_csv)).to eq []
    end
  end

  context "when some records are present" do
    it "returns unanswered, and non transfered-out pqs, within the supplied date range" do
      mk_pq('uin-1', answer_submitted: Date.today - 5)
      mk_pq('uin-1', tabled_date: Date.today)
    end
  end
end
