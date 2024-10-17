require "rails_helper"

describe "PqState#progress_changer" do
  def stub_pq(overrides = {})
    instance_double(Pq,
                    {
                      no_response?: true,
                      rejected?: false,
                      action_officers_pqs: double("ao-pqs", any?: true, all_rejected?: false), # rubocop:disable RSpec/VerifiedDoubles
                      action_officer_accepted: nil,
                      transfer_out_ogd_id: nil,
                    }.merge(overrides))
  end

  subject(:changer) do
    PqState.progress_changer
  end

  describe "#validate_transition_graph!" do
    it "does not raise errors" do
      expect {
        changer.validate_transition_graph!
      }.not_to raise_error
    end
  end

  describe "#next_state" do
    context "when moving from the initial, to an intermediate state of the graph" do
      it "returns the intermediate state" do
        expect(changer.next_state(PqState::UNASSIGNED, stub_pq)).to eq(PqState::NO_RESPONSE)
      end
    end

    context "when moving from an intermediate state to a possible final state" do
      it "returns the final state" do
        pq = stub_pq(transfer_out_ogd_id: "test-id",
                     transfer_out_date: Time.zone.now)

        expect(changer.next_state(PqState::NO_RESPONSE, pq)).to eq(PqState::TRANSFERRED_OUT)
      end
    end

    context "when moving from the initial to the final state" do
      it "returns the final state" do
        pq = stub_pq(transfer_out_ogd_id: "test-id",
                     transfer_out_date: Time.zone.now,
                     action_officer_accepted: instance_double(ActionOfficer),
                     draft_answer_received: Time.zone.now,
                     pod_clearance: true,
                     policy_minister: nil,
                     sent_to_answering_minister: Time.zone.today,
                     cleared_by_answering_minister: true,
                     answer_submitted: Time.zone.today)

        expect(changer.next_state(PqState::UNASSIGNED, pq)).to eq(PqState::ANSWERED)
      end
    end
  end
end
