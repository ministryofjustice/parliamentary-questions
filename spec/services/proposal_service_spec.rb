require "rails_helper"

describe ProposalService do
  shared_context "with test_values" do
    let(:ao1)                 { DbHelpers.action_officers[0] }
    let(:ao2)                 { DbHelpers.action_officers[1] }
    let(:form)                { ProposalForm.new(form_params) }
    let(:invalid_form_params) { form_params.merge(action_officer_id: [""]) }
    let(:invalid_form)        { ProposalForm.new(invalid_form_params) }
    let(:pq)                  { DbHelpers.pqs.first }
    let(:form_params)         do
      {
        pq_id: pq.id,
        action_officer_id: [ao1.id, ao2.id],
      }
    end
  end

  describe "propose" do
    include_context "with test_values"
    context "when the supplied form data is not valid" do
      it "raises an error" do
        expect {
          invalid_form = ProposalForm.new(invalid_form_params)
          described_class.new.propose(invalid_form)
        }.to raise_error(ArgumentError)
      end
    end

    context "when the supplied data is valid" do
      let(:valid_form) { ProposalForm.new(form_params) }
      let(:pq1) { described_class.new.propose(valid_form) }

      it "returns an updated PQ" do
        expect(pq1).to be_valid
      end

      it "sets the pqs' action officers" do
        expect(pq1.action_officers).to eq([ao1, ao2])
      end

      it "keeps the PQ state as unassigned" do
        expect(pq1.state).to eq(PqState::UNASSIGNED)
      end
    end
  end
end
