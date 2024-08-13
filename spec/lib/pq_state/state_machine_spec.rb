require "rails_helper"

describe "PqState" do
  let(:pq) { instance_double(Pq) }

  let(:transitions) do
    pred = proc { true }
    [
      PqState::Transition.new("a", "b", pred),
      PqState::Transition.new("b", "c", pred),
      PqState::Transition.new("c", "final_state", pred),
    ]
  end

  let(:state_machine) do
    PqState::StateMachine.new(%w[final_state], transitions)
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
