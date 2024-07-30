require "rails_helper"

describe ProposalForm, type: :model do
  describe "validation error messages" do
    subject { form.errors.map(&:message) }

    let(:form) { build(:proposal_form) }

    before do
      form.valid?
    end

    context "when pq_id is missing" do
      let(:form) { build(:proposal_form, pq_id: nil) }

      it { is_expected.to include("Please provide question id to proposal") }
    end

    context "when action_officer_id is missing" do
      let(:form) { build(:proposal_form, action_officer_id: nil) }

      it { is_expected.to include("Please select at least one action officer") }
    end

    context "when action_officer_id is empty" do
      let(:form) { build(:proposal_form, action_officer_id: [""]) }

      it { is_expected.to include("Please select at least one action officer") }
    end

    context "when action officer is invalid" do
      let(:form) { build(:proposal_form, pq_id: 1, action_officer_id: %w[invalid]) }

      it { is_expected.to include("Please select valid action officer") }
    end

    context "when all required fields are provided" do
      it { is_expected.to be_empty }
    end
  end
end
