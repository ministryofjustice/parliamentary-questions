require 'spec_helper'

describe Pq do
  let(:subject) {build(:question)}

  describe '#update' do
    it 'transitions after assigning attributes' do
      expect(subject).to receive(:transition) do
        expect(subject.text).to eq 'updated question'
      end
      subject.update({text: 'updated question'})
    end

    it 'saves' do
      expect(subject).to receive(:save)
      subject.update({})
    end
  end

  describe "associations" do
    it { is_expected.to belong_to :minister }
    it { is_expected.to belong_to :policy_minister }
    it { is_expected.to have_one :trim_link }
    it { is_expected.to belong_to :directorate }
    it { is_expected.to belong_to :division }
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

    describe '#no_policy_minister' do
      context 'when no policy minister' do
        it 'returns true' do
          subject.valid?
          expect(subject.no_policy_minister).to be true
        end
      end

      context 'when there is a policy minister' do
        before { subject.policy_minister = build(:minister) }
        it 'returns false' do
          subject.valid?
          expect(subject.no_policy_minister).to be false
        end
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
    let!(:older_pq) { create(:question_with_officers, action_officer_allocated_at: 2.days.ago)}
    let!(:new_pq1) { create(:question_with_officers, uin: '20001',
      action_officer_allocated_at: 3.hours.from_now)}
    let!(:new_pq2) { create(:question_with_officers, uin: 'HL01',
      action_officer_allocated_at: 5.hours.from_now)}
    let!(:new_pq3) { create(:question_with_officers, uin: '15000',
      action_officer_allocated_at: 5.hours.from_now)}

    subject { Pq.allocated_since(Time.now) }

    it 'returns questions commissioned from given time' do
      expect(subject.length).to be(3)
    end

    it 'returns questions ordered by uin' do
      expect(subject.map(&:uin)).to eql(%w(15000 20001 HL01))
    end
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

      # TODO move to validator in state machine tests
      # describe '#all_rejected?' do
      #   it 'returns true when all action officers have rejected' do
      #     accepted.reject(nil, nil)
      #     awaiting.reject(nil, nil)
      #     expect(subject.action_officers_pqs).to be_all_rejected
      #   end
      #
      #   it 'returns false when an action officer has not responded' do
      #     accepted.reject(nil, nil)
      #     expect(subject.action_officers_pqs).not_to be_all_rejected
      #   end
      #
      #   it 'returns false when an action officer has accepted' do
      #     awaiting.reject(nil, nil)
      #     expect(subject.action_officers_pqs).not_to be_all_rejected
      #   end
      # end
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

  describe '#closed?' do
    it 'is closed when answered' do
      subject = build(:question_answered)
      expect(subject.closed?).to be true
    end

    it 'is not closed when unanswered' do
      subject = build(:question)
      expect(subject.closed?).to be false
    end
  end

  describe '#open?' do
    it 'open when unanswered' do
      subject = build(:question)
      expect(subject.open?).to be true
    end

    it 'not open when answered' do
      subject = build(:question_answered)
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
