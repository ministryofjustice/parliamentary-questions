# == Schema Information
#
# Table name: action_officers_pqs
#
#  id                :integer          not null, primary key
#  pq_id             :integer          not null
#  action_officer_id :integer          not null
#  reason            :text
#  reason_option     :string
#  updated_at        :datetime
#  created_at        :datetime
#  reminder_accept   :integer          default(0)
#  reminder_draft    :integer          default(0)
#  response          :string           default("awaiting")
#

require "rails_helper"

describe ActionOfficersPq do
  subject(:action_officers_pq) { described_class.new pq: create(:pq), action_officer: create(:action_officer) }

  describe "relationships" do
    it { is_expected.to belong_to :pq }
    it { is_expected.to belong_to :action_officer }
  end

  describe "#accept" do
    before { action_officers_pq.accept }

    it { is_expected.to be_accepted }
  end

  describe "#reject" do
    before { action_officers_pq.reject("option", "reason") }

    it { is_expected.to be_rejected }

    it "sets reason option" do
      expect(action_officers_pq.reason_option).to eq "option"
    end

    it "sets reason" do
      expect(action_officers_pq.reason).to eq "reason"
    end
  end

  describe "#reset" do
    before do
      action_officers_pq.response = :accepted
      action_officers_pq.reset
    end

    it "marks as awaiting" do
      expect(action_officers_pq.reload.response).to eq :awaiting
    end
  end

  describe "states" do
    { awaiting: :awaiting_response, accepted: :accepted, rejected: :rejected }.each do |state, check|
      context "when #{check}" do
        subject { described_class.new response: state }

        it { is_expected.to send("be_#{check}") }
      end

      context "when not #{state}" do
        subject { described_class.new response: :other_state }

        it { is_expected.not_to send("be_#{check}") }
      end
    end
  end
end
