# == Schema Information
#
# Table name: tokens
#
#  id           :integer          not null, primary key
#  path         :string
#  token_digest :string
#  expire       :datetime
#  entity       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  acknowledged :string
#  ack_time     :datetime
#

require "spec_helper"

describe Token, type: :model do
  describe "accept/reject" do
    let(:token)         { FactoryBot.create :token }
    let(:frozen_time)   { Time.utc(2015, 5, 19, 12, 47, 33) }

    it "marks date and time it was accepted" do
      Timecop.freeze frozen_time do
        token.accept
        token.reload
        expect(token.acknowledged).to eq "accept"
        expect(token.ack_time).to eq frozen_time
      end
    end

    it "marks date and time it was rejected" do
      Timecop.freeze frozen_time do
        token.reject
        token.reload
        expect(token.acknowledged).to eq "reject"
        expect(token.ack_time).to eq frozen_time
      end
    end
  end

  describe "acknowledged?" do
    subject(:token) { FactoryBot.create :token }

    it "allow acknowledged to be accepted" do
      expect(token).to allow_value("accept").for(:acknowledged)
    end

    it "allow acknowledged to be rejected" do
      expect(token).to allow_value("reject").for(:acknowledged)
    end

    it "allow acknowledged to be nil" do
      expect(token).to allow_value(nil).for(:acknowledged)
    end

    it "not allow acknowledged to be giddykipper" do
      expect(token).not_to allow_value("giddykipper").for(:acknowledged).with_message("giddykipper is not a valid value for acknowledged")
    end

    it "returns true if accepted" do
      t = FactoryBot.build(:token, acknowledged: "accept")
      expect(t.acknowledged?).to be true
    end

    it "returns true if rejected" do
      t = FactoryBot.build(:token, acknowledged: "reject")
      expect(t.acknowledged?).to be true
    end

    it "returns false if neither" do
      t = FactoryBot.build(:token)
      expect(t.acknowledged?).to be false
    end
  end

  describe ".watchlist_status" do
    let(:entity) { "watchlist-#{Time.zone.today.strftime('%d/%m/%Y')} 11:37" }
    let!(:token) { FactoryBot.create :token, path: "/watchlist/dashboard", entity: }

    it "returns false if the token has not been acknowledged" do
      expect(described_class.watchlist_status).to be false
    end

    it "returns true if the token has been acknowledged" do
      token.accept
      expect(described_class.watchlist_status).to be true
    end
  end

  describe ".assignment_stats" do
    it "returns the total number of assignment tokens and the number of unanswered assignment tokens" do
      start_of_day = Time.zone.now.beginning_of_day
      FactoryBot.create :token, created_at: start_of_day + 100.minutes
      FactoryBot.create :token, created_at: start_of_day + 200.minutes
      FactoryBot.create :token, created_at: start_of_day + 300.minutes
      FactoryBot.create :token, created_at: start_of_day - 100.minutes
      FactoryBot.create :token, created_at: start_of_day - 100.minutes
      FactoryBot.create :token, created_at: start_of_day + 100.minutes
      FactoryBot.create :token, created_at: start_of_day + 200.minutes, acknowledged: "accept", ack_time: start_of_day + 400.minutes
      FactoryBot.create :token, created_at: start_of_day + 300.minutes, acknowledged: "accept", ack_time: start_of_day + 400.minutes
      FactoryBot.create :token, created_at: start_of_day - 100.minutes, acknowledged: "accept", ack_time: start_of_day + 400.minutes
      FactoryBot.create :token, created_at: start_of_day - 100.minutes, acknowledged: "reject", ack_time: start_of_day + 400.minutes
      expect(described_class.assignment_stats).to eq(
        total: 6,
        ack: 2,
        open: 4,
        pctg: 33.33,
      )
    end
  end
end
