require 'spec_helper'

describe Pq do
  let(:subject) {build(:question)}

  describe "associations" do
    it { is_expected.to belong_to :minister }
    it { is_expected.to belong_to :policy_minister }
    it { is_expected.to have_one :trim_link }
    it { is_expected.to belong_to :directorate }
    it { is_expected.to belong_to :division }
  end

  describe 'association methods' do
    let!(:accepted) { create(:accepted_action_officers_pq, pq: subject) }
    let!(:awaiting) { create(:action_officers_pq, pq: subject) }

    before do
      2.times { create(:rejected_action_officers_pq, pq: subject) }
    end

    describe '#action_officers_pq' do
      describe '#accepted' do
        it 'returns 1 record' do
          expect(subject.action_officers_pqs.accepted).to eq [accepted]
        end
      end

      describe '#rejected' do
        it 'returns 2 records' do
          expect(subject.action_officers_pqs.rejected.count).to eq 2
        end
      end
    end

    describe '#action_officers' do
      describe '#accepted' do
        it 'returns the accepted action officer' do
          expect(subject.action_officers.accepted).to eq [accepted.action_officer]
        end
      end

      describe '#rejected' do
        it 'returns 2 records' do
          expect(subject.action_officers.rejected.count).to eq 2
        end
      end
    end
  end

  describe 'factories' do
    QuestionStateMachine::STATES.each do |state|
      context "when creating factory :question_#{state}" do
        subject { create("question_#{state}").reload }
        it { is_expected.to send("be_#{state}") }
      end
    end
  end

  describe '#transition' do
    it 'saves' do
      expect(subject).to receive(:save)
      subject.transition
    end
  end

  describe 'callbacks' do
    it 'always returns true to allow callbacks to run' do
      allow(subject).to receive(:state_machine) { double transition: false }
      expect(subject).to receive(:set_state)
      subject.save
    end
  end

  describe '#set_non_model_attributes_for_transitions' do
    it { is_expected.to be_valid }

    describe '#action_officers_present' do
      before { subject.action_officers << build(:action_officer) }
      it 'returns true' do
        subject.valid?
        expect(subject.action_officers_present).to be true
      end
    end

    describe '#all_action_officers_rejected' do
      subject { create :question_rejected }

      context 'when all action officers rejected' do
        it 'returns true' do
          subject.valid?
          expect(subject.all_action_officers_rejected).to be true
        end
      end

      context 'when only some action officers rejected' do
        before { subject.action_officers_pqs << build(:action_officers_pq) }
        it 'returns true' do
          subject.valid?
          expect(subject.all_action_officers_rejected).to be false
        end
      end
    end
  end

  describe '#reassign' do
    subject { create(:question_draft_pending) }
    let!(:original_assignment) { subject.accepted_assignment }
    let(:new_assignment) { create :action_officers_pq, pq: subject }
    let(:new_action_officer) { new_assignment.action_officer }
    let(:division) { new_action_officer.deputy_director.division }
    let(:directorate) { division.directorate }

    before do
      subject.action_officers << new_action_officer
    end

    it 'assigns a new action officer' do
      subject.reassign new_action_officer

      expect(original_assignment.reload.response).to eq :awaiting
      expect(new_assignment.reload).to be_accepted
      expect(subject.division).to eq(division)
      expect(subject.directorate).to eq(directorate)
    end

    context 'when reassigning to an action officer already commissioned (in the list)' do
      it 'assigns to other action officer' do
        subject.action_officers_pqs << new_assignment
        subject.reassign new_action_officer

        expect(original_assignment.reload.response).to eq :awaiting
        expect(new_assignment.reload).to be_accepted
      end
    end

    context 'when reassigning to the same action officer' do
      it 'ignores change' do
        subject.reassign new_action_officer

        expect(subject).not_to receive(:update)
        subject.reassign new_action_officer
      end
    end

    context 'when nil' do
      it 'ignores change' do
        expect(subject).not_to receive(:action_officers_pqs)
        subject.reassign nil
      end
    end
  end

  describe '#ministers_by_state' do
    let(:minister) { create(:minister) }
    let(:policy_minister) { create(:minister) }
    let(:states) { QuestionStateMachine.in_progress }

    before do
      states.each do |state|
        factory = "question_#{state}"
        create(factory, minister: minister, policy_minister: policy_minister)
        create(factory, minister: policy_minister)
      end
    end

    it 'returns table summed by questions in states grouped by minister not counting policy minister' do
      minister_counts = states.map{|state| [[minister.id, state], 1] }
      policy_minister_counts = states.map{|state| [[policy_minister.id, state], 1] }

      expect(Pq.ministers_by_state([minister, policy_minister], states)).to eq(
      (minister_counts + policy_minister_counts).to_h
      )
    end
  end

  describe '.allocated_since' do
    let!(:oldest_question) { create(:question_awaiting_response, uin: '1000', age: 2.days.ago)}
    let!(:newest_question) { create(:question_awaiting_response, uin: '20001', age: 3.hours.ago)}
    let!(:older_question) { create(:question_awaiting_response, uin: 'HL01', age: 5.hours.ago)}
    let!(:new_question) { create(:question_awaiting_response, uin: '15000', age: 4.hours.ago)}

    let(:results) { Pq.allocated_since(Date.yesterday) }

    it 'returns questions ordered by uin' do
      expect(results.map(&:uin)).to eql(%w(15000 20001 HL01))
    end
  end

  describe 'state scopes' do
    let!(:with_finance) { create(:question) }
    let!(:rejected) { create(:question_rejected) }
    let!(:draft_pending) { create(:question_draft_pending) }
    let!(:with_pod) { create(:question_with_pod) }

    describe '.new_questions' do
      it 'returns the correct questions' do
        expect(Pq.new_questions.order('id')).to eq [with_finance, rejected]
      end
    end

    describe '.in_progress' do
      it 'returns the correct questions' do
        expect(Pq.in_progress.order('id')).to eq [draft_pending, with_pod]
      end
    end

    describe '.in_state' do
      it 'returns the correct questions' do
        expect(Pq.in_state([:with_finance, :with_pod]).order('id')).to eq [with_finance, with_pod]
      end
    end
  end

  describe '#has_trim_link?' do
    context 'when trim link present' do
      before { subject.trim_link = TrimLink.new }
      it { is_expected.to have_trim_link }
    end

    context 'when no trim link' do
      it { is_expected.not_to have_trim_link }
    end

    context 'when trim link deleted' do
      before { subject.trim_link = TrimLink.new deleted: true }
      it { is_expected.not_to have_trim_link }
    end
  end

  describe '#seen_by_finance' do
    it 'returns false when "0" from user input' do
      subject.seen_by_finance = '0'
      expect(subject.seen_by_finance).to be false
    end

    it 'returns true when "1" from user input' do
      subject.seen_by_finance = '1'
      expect(subject.seen_by_finance).to be true
    end

    it 'returns true when not with finance' do
      subject.state_machine.state = :uncommissioned
      expect(subject.seen_by_finance).to be true
    end

    it 'returns false when with finance' do
      subject.state_machine.state = :with_finance
      expect(subject.seen_by_finance).to be false
    end
  end

  describe '#seen_by_finance?' do
    before { subject.seen_by_finance = '1' }
    it { is_expected.to be_seen_by_finance }
  end

  describe '#pod_official_interest' do
    it 'returns false when "0" from user input' do
      subject.pod_official_interest = '0'
      expect(subject.pod_official_interest).to be false
    end

    it 'returns true when "1" from user input' do
      subject.seen_by_finance = '1'
      expect(subject.pod_official_interest).to be true
    end

    it 'returns false when not with POD official' do
      subject.state_machine.state = :pod_cleared
      expect(subject.pod_official_interest).to be false
    end

    it 'returns true when with POD official' do
      subject.state_machine.state = :with_pod_official
      expect(subject.pod_official_interest).to be true
    end
  end

  describe '#pod_official_interest?' do
    before { subject.pod_official_interest = '1' }
    it { is_expected.to be_pod_official_interest }
  end

  describe '#closed?' do
    it 'is closed when answered' do
      subject = create(:question_answered)
      expect(subject.closed?).to be true
    end

    it 'is not closed when unanswered' do
      subject = build(:question)
      expect(subject.closed?).to be false
    end
  end

  describe '#open?' do
    it 'open when unanswered' do
      subject = create(:question)
      expect(subject.open?).to be true
    end

    it 'not open when answered' do
      subject = create(:question_answered)
      expect(subject.open?).to be false
    end
  end

  describe 'validation' do
    it 'should pass onfactory build' do
      expect(subject).to be_valid
    end

    it 'should have a Uin' do
      subject.uin=nil
      expect(subject).to be_invalid
    end

    it 'should have a Raising MP ID' do
      subject.raising_member_id=nil
      expect(subject).to be_invalid
    end

    it 'should have text' do
      subject.text = nil
      expect(subject).to be_invalid
    end

    describe '#sanitize_uin' do
      it 'strips any whitespace from uin' do
        subject.uin = ' hl1 234 '
        subject.valid?
        expect(subject.uin).to eq 'hl1234'
      end
    end
  end

  describe 'item' do
    it 'should allow finance interest to be set' do
      subject.finance_interest=true
      expect(subject).to be_valid
      subject.finance_interest=false
      expect(subject).to be_valid
    end
  end
end
