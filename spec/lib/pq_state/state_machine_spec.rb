require "spec_helper"

describe "PQState" do
  let(:pq) { instance_double("pq-stub") }

  let(:transitions) do
    pred = proc { true }
    [
      PQState::Transition.new("a", "b", pred),
      PQState::Transition.new("b", "c", pred),
      PQState::Transition.new("c", "final_state", pred),
    ]
  end

  let(:state_machine) do
    PQState::StateMachine.new(%w[final_state], transitions)
  end

  describe "#next_state" do
    context "when the supplied state does not exist" do
      it "raises an ArgumentError" do
        expect {
          state_machine.next_state("missing-state", pq)
        }.to raise_error(ArgumentError, /cannot find a transition from state/i)
      end
    end

    context "when the supplied state exists" do
      it "returns the next valid state" do
        expect(state_machine.next_state("a", pq)).to eq("final_state")
      end
    end
  end
end
