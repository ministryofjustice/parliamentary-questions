require 'spec_helper'

describe QuestionStateMachine do
  let(:model) { spy state: nil }
  subject { described_class.new model }

  describe 'STATES' do
    it 'ensures order is kept for use as integer states by question model' do
      expect(QuestionStateMachine::STATES).to eq [
        :with_finance,
        :uncommissioned,
        :with_officers,
        :rejected,
        :draft_pending,
        :with_pod,
        :pod_cleared,
        :with_policy_minister,
        :policy_minister_cleared,
        :with_answering_minister,
        :answering_minister_cleared,
        :answered,
        :withdrawn,
        :transferred_out,
      ]
    end
  end

  describe '.indexes_for' do
    it 'returns indexes for given states' do
      expect(subject.class.indexes_for(:with_finance, :pod_cleared)).to eq [0, 6]
    end
  end

  describe '#state' do
    it 'is initially nil' do
      expect(subject.state).to be nil
    end

    it 'has state from the model' do
      allow(model).to receive(:state).and_return 0
      expect(subject.state).to eq :with_finance
    end
  end

  describe '#index' do
    it 'is initially nil' do
      expect(subject.index).to be nil
    end

    it 'returns index associated with state' do
      allow(model).to receive(:state).and_return 0
      expect(subject.index).to eq 0
    end
  end

  describe '#new_question?' do
    context "when :with_finance" do
      before { subject.state = :with_finance }
      it { is_expected.to be_new_question }
    end

    context 'when :draft_pending' do
      before { subject.state = :draft_pending }
      it { is_expected.not_to be_new_question }
    end
  end

  describe '#closed?' do
    [:withdrawn, :answered, :transferred_out].each do |state|
      context "when :#{state}" do
        before { subject.state = state }
        it { is_expected.to be_closed }
      end
    end

    context 'when :draft_pending' do
      before { subject.state = :draft_pending }
      it { is_expected.not_to be_closed }
    end
  end

  describe '#available_transitions' do
    it 'returns "to" states for current state' do
      subject.state = :with_officers
      expect(subject.available_transitions).to eq([
        QuestionStateMachine::Transition.new(:with_officers, :rejected),
        QuestionStateMachine::Transition.new(:with_officers, :draft_pending),
        QuestionStateMachine::Transition.new(:with_officers, :transferred_out),
        QuestionStateMachine::Transition.new(:with_officers, :uncommissioned)
      ])
    end
  end

  describe '#transition on real model' do
    let(:model) { create(:question_pod_cleared) }

    context 'when sent to answering minister and no policy minister' do
      before do
        model.sent_to_answering_minister = Date.today
        model.policy_minister = nil
      end

      it 'transitions to :with_answering_minister' do
        subject.transition
        expect(subject.state).to eq :with_answering_minister
      end
    end

  end

  describe '#transition' do
    class DummyErrors
      def clear
        @errors = false
      end

      def add(attribute, message)
        @errors = true
      end

      def empty?
        !@errors
      end
    end

    let(:errors) { DummyErrors.new }
    let(:attributes) { [] }

    before do
      allow(model).to receive(:run_callbacks)
      allow(ActiveModel::Errors).to receive(:new).and_return errors
      attributes.each do |attribute, value|
        allow(model).to receive(attribute).and_return value
      end
    end

    def model_state state
      allow(model).to receive(:state).and_return QuestionStateMachine::index_for(state)
    end

    def expects_transition_to state
      expect(subject.transition).to be true
      expect(subject.state).to eq state
    end

    def expects_not_to_transition
      expect(subject.transition).to be nil
    end

    it 'ensure validation callbacks are run' do
      expect(model).to receive(:run_callbacks).with(:validation)
      subject.transition
    end

    context 'when :with_finance' do
      before { model_state :with_finance }

      context 'when finance cleared' do
        let(:attributes) { {seen_by_finance: true} }
        it { expects_transition_to :uncommissioned }
      end
    end

    context 'when :uncommissioned' do
      before { model_state :uncommissioned }

      context 'when finance have not cleared' do
        let(:attributes) { {seen_by_finance: false} }
        it { expects_transition_to :with_finance }
      end

      context 'when action officers are assigned' do
        let(:attributes) { {action_officers_present: true} }
        it { expects_transition_to :with_officers }
      end
    end

    context 'when :with_officers' do
      before { model_state :with_officers }

      context 'when no action officers are assigned' do
        let(:attributes) { {action_officers_present: false} }
        it { expects_transition_to :uncommissioned }
      end

      context 'when all action officers are rejected' do
        let(:attributes) { {all_action_officers_rejected: true} }
        it { expects_transition_to :rejected }
      end

      context 'when an action officer accepted' do
        let(:attributes) { {accepted_action_officer: double} }
        it { expects_transition_to :draft_pending }
      end
    end

    context 'when :draft_pending' do
      before { model_state :draft_pending }

      context 'when no accepted action officer' do
        let(:attributes) { {accepted_action_officer: nil} }
        it { expects_transition_to :with_officers }
      end

      context 'when draft answered received' do
        let(:attributes) { {draft_answer_received: double} }
        it { expects_transition_to :with_pod }
      end
    end

    context 'when :with_pod' do
      before { model_state :with_pod }

      context 'when no draft answer received' do
        let(:attributes) { {draft_answer_received: nil} }
        it { expects_transition_to :draft_pending }
      end

      context 'when pod cleared' do
        let(:attributes) { {pod_clearance: double} }
        it { expects_transition_to :pod_cleared }
      end
    end

    context 'when :pod_cleared' do
      before { model_state :pod_cleared }

      context 'when no pod clearance' do
        let(:attributes) { {pod_clearance: nil} }
        it { expects_transition_to :with_pod }
      end

      context 'when sent to answering minister and there is a policy minister' do
        let(:attributes) { {sent_to_policy_minister: double, policy_minister: double} }
        it { expects_transition_to :with_policy_minister }
      end

      context 'when sent to answering minister and no policy minister' do
        let(:attributes) { {sent_to_answering_minister: double, no_policy_minister: true} }
        it { expects_transition_to :with_answering_minister }
      end
    end

    context 'when :with_policy_minister' do
      before { model_state :with_policy_minister }

      context 'when not sent to policy minister' do
        let(:attributes) { {sent_to_policy_minister: nil, policy_minister: double} }
        it { expects_transition_to :pod_cleared }
      end

      context 'when cleared by policy minister' do
        let(:attributes) { {cleared_by_policy_minister: double} }
        it { expects_transition_to :policy_minister_cleared }
      end
    end

    context 'when :policy_minister_cleared' do
      before { model_state :policy_minister_cleared }

      context 'when not cleared by policy minister' do
        let(:attributes) { {cleared_by_policy_minister: nil} }
        it { expects_transition_to :with_policy_minister }
      end

      context 'when sent to answering minister' do
        let(:attributes) { {sent_to_answering_minister: double, policy_minister: double} }
        it { expects_transition_to :with_answering_minister }
      end
    end

    context 'when :with_answering_minister' do
      before { model_state :with_answering_minister }

      context 'when not sent_to_answering_minister but has a policy minister' do
        let(:attributes) { {sent_to_answering_minister: nil, policy_minister: double} }
        it { expects_transition_to :policy_minister_cleared }
      end

      context 'when not sent_to_answering_minister and has no policy minister' do
        let(:attributes) { {sent_to_answering_minister: nil, no_policy_minister: true} }
        it { expects_transition_to :pod_cleared }
      end

      context 'when cleared_by_answering_minister' do
        let(:attributes) { {cleared_by_answering_minister: double} }
        it { expects_transition_to :answering_minister_cleared }
      end
    end

    context 'when :answering_minister_cleared' do
      before { model_state :answering_minister_cleared }

      context 'when not cleared_by_answering_minister' do
        let(:attributes) { {cleared_by_answering_minister: nil} }
        it { expects_transition_to :with_answering_minister }
      end

      context 'when answered' do
        let(:attributes) { {answer_submitted: double} }
        it { expects_transition_to :answered }
      end

      context 'when withdown' do
        let(:attributes) { {pq_withdrawn: double} }
        it { expects_transition_to :withdrawn }
      end
    end

    context 'when :answered' do
      before { model_state :answered }

      context 'when answer not submitted' do
        let(:attributes) { {answer_submitted: nil} }
        it { expects_transition_to :answering_minister_cleared }
      end

      context 'when answer submitted' do
        let(:attributes) { {answer_submitted: double} }
        it { expects_not_to_transition }
      end
    end

    context 'when :withdrawn' do
      before { model_state :withdrawn }

      context 'when question not withdrawn' do
        let(:attributes) { {pq_withdrawn: nil} }
        it { expects_transition_to :answering_minister_cleared }
      end

      context 'when question withdrawn' do
        let(:attributes) { {pq_withdrawn: double} }
        it { expects_not_to_transition }
      end
    end

    [:uncommissioned, :with_officers, :rejected].each do |state|
      context "when :#{state}" do
        before { model_state state }

        let(:attributes) { {transfer_out_ogd_id: 1, transfer_out_date: double} }
        it { expects_transition_to :transferred_out }
      end

      context "when :transferred_out" do
        it "cannot be reversed to :#{state}" do
          reverse_transition = QuestionStateMachine::Transition.new(:transferred_out, state)
          expect(subject.class.reverse_transitions.find{|rt| rt == reverse_transition}).to be nil
        end
      end
    end

    context 'when :with_finance' do
      before { model_state :with_finance }

      let(:attributes) { {transfer_out_ogd_id: 1, transfer_out_date: double} }
      it { expects_transition_to :transferred_out }
    end

    context "when :transferred_out" do
      before { model_state :transferred_out }
      it { expects_transition_to :with_finance }
    end
  end
end
