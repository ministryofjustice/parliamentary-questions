require 'spec_helper'

describe Pq do
  let(:subject) {build(:pq)}

  describe "associations" do
    it { is_expected.to belong_to :minister }
    it { is_expected.to belong_to :policy_minister }
    it { is_expected.to have_one :trim_link }
    it { is_expected.to belong_to :directorate }
    it { is_expected.to belong_to :division }
  end

  describe ".before_update" do
    it "sets the state weight" do
      state    = PQState::DRAFT_PENDING
      pq, _    = DBHelpers.pqs
      pq.update(state: state)
      expect(pq.state_weight).to eq(PQState.state_weight(state))
    end
  end

  describe ".accepted_by_press_desk" do
    def accept_pq(pq, ao)
      pq.action_officers_pqs << ActionOfficersPq.new(action_officer: ao,
                                                     response: 'accepted',
                                                     pq: pq)
      pq.save
    end

    context "when no data exist" do
      it "returns an empty hash" do
        expect(Pq.accepted_by_press_desk).to eq({})
      end
    end

    context "when some data exist" do
      before do
        @pd1, @pd2             = DBHelpers.press_desks
        @ao1, @ao2, @ao3       = DBHelpers.action_officers
        @pq1, @pq2, @pq3, @pq4 = DBHelpers.pqs

        @pq1.state = PQState::NO_RESPONSE
        @pq2.state = PQState::WITH_POD
        @pq3.state = PQState::WITH_POD

        accept_pq(@pq1, @ao1)
        accept_pq(@pq2, @ao2)
        accept_pq(@pq3, @ao3)
      end

      it "returns a hash with states as keys and press-desk/counts as values" do
        expect(Pq.accepted_by_press_desk).to eq({
          PQState::NO_RESPONSE => {
            @pd1.id => 1
          },
          PQState::WITH_POD => {
            @pd2.id => 2
          }
        })
      end

      context "when a press desk gets deleted" do
        before do
          @pd1.deactivate!
        end

        it "omits the associated questions from the results" do
          expect(Pq.accepted_by_press_desk).to eq({
            PQState::WITH_POD => {
              @pd2.id => 2
            }
          })
        end
      end
    end
  end

  describe ".in_progress_by_minister" do
    context "when no data exist" do
      it "returns an empty hash" do
        expect(Pq.in_progress_by_minister).to eq({})
      end
    end

    context "when some data exist" do
      before do
        @minister1, @minister2, _ = DBHelpers.ministers
        @pq1, @pq2, @pq3, @pq4    = DBHelpers.pqs

        @pq1.update(state: PQState::DRAFT_PENDING, minister: @minister1)
        @pq2.update(state: PQState::WITH_MINISTER, minister: @minister2)
        @pq3.update(state: PQState::ANSWERED, minister: @minister2)
        # ^ should not be included as its state is not included in PQState::IN_PROGRESS
        @pq4.update(state: PQState::DRAFT_PENDING, minister: @minister2)
      end

      it "returns a hash with states as keys and minister counts as values" do
        expect(Pq.in_progress_by_minister).to eq({
          PQState::DRAFT_PENDING => {
            @minister1.id => 1,
            @minister2.id => 1,
          },
          PQState::WITH_MINISTER => {
            @minister2.id => 1
          }
        })
      end

      context "when a minister becomes inactive" do
        before do
          @minister1.deactivate!
        end

        it "omits the minister and its related PQ count from the results" do
          expect(Pq.in_progress_by_minister).to eq({
            PQState::DRAFT_PENDING => {
              @minister2.id => 1,
            },
            PQState::WITH_MINISTER => {
              @minister2.id => 1
            }
          })
        end
      end
    end
  end

  describe ".filter_for_report" do
    def commission_and_accept(pq, ao)
      pq.update(state: PQState::WITH_POD)
    end

    before do
      @pq1, @pq2, @pq3, @pq4 = DBHelpers.pqs
    end

    context "when state, minister or press desk are all nil" do
      it "returns all the records"
    end
    context "when state, minister or press desk are all present" do
      it "returns the expected records"
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

  describe '#not_seen_by_finance' do
    subject! { create(:pq) }
    before { create(:checked_by_finance_pq) }
    it { expect(described_class.not_seen_by_finance).to eq [subject] }
  end

  describe 'allocated_since' do
    let!(:older_pq) { create(:not_responded_pq, action_officer_allocated_at: Time.now - 2.days)}
    let!(:new_pq1) { create(:not_responded_pq, uin: '20001', action_officer_allocated_at: Time.now + 3.hours)}
    let!(:new_pq2) { create(:not_responded_pq, uin: 'HL01',  action_officer_allocated_at: Time.now + 5.hours)}
    let!(:new_pq3) { create(:not_responded_pq, uin: '15000', action_officer_allocated_at: Time.now + 5.hours)}

    subject { Pq.allocated_since(Time.now) }

    it 'returns questions allocated from given time' do
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
          expect(subject.action_officers_pqs.accepted).to eq accepted
        end
      end

      describe '#rejected' do
        it 'returns 2 records' do
          expect(subject.action_officers_pqs.rejected.count).to eq 2
        end
      end

      describe '#all_rejected?' do
        it 'returns true when all action officers have rejected' do
          accepted.reject(nil, nil)
          awaiting.reject(nil, nil)
          expect(subject.action_officers_pqs).to be_all_rejected
        end

        it 'returns false when an action officer has not responded' do
          accepted.reject(nil, nil)
          expect(subject.action_officers_pqs).not_to be_all_rejected
        end

        it 'returns false when an action officer has accepted' do
          awaiting.reject(nil, nil)
          expect(subject.action_officers_pqs).not_to be_all_rejected
        end
      end
    end

    describe '#action_officers' do
      describe '#accepted' do
        it 'returns 1 record' do
          expect(subject.action_officers.accepted).to eq accepted.action_officer
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
    subject { create(:draft_pending_pq) }
    let!(:original_assignment) { subject.ao_pq_accepted }
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

    context 'when nil' do
      it 'ignores change' do
        expect(subject).not_to receive(:action_officers_pqs)
        subject.reassign nil
      end
    end
  end

  describe '#commissioned?' do
    subject { create(:pq) }

    context 'when no officer is assigned' do
      it { is_expected.not_to be_commissioned}
    end

    context 'when all assigned officers are rejected' do
      before do
        subject.action_officers_pqs.create(action_officer: create(:action_officer), response: 'rejected')
      end

      it { is_expected.not_to be_commissioned}
    end

    context 'when some assigned officers are not rejected' do
      before do
        subject.action_officers_pqs.create(action_officer: create(:action_officer))
        subject.action_officers_pqs.create(action_officer: create(:action_officer), response: 'rejected')
      end

      it { is_expected.to be_commissioned}
    end
  end

  describe '#closed?' do
    it 'is closed when answered' do
      subject = build(:answered_pq)
      expect(subject.closed?).to be true
    end

    it 'is not closed when unanswered' do
      subject = build(:pq)
      expect(subject.closed?).to be false
    end
  end

  describe '#open?' do
    it 'open when unanswered' do
      subject = build(:pq)
      expect(subject.open?).to be true
    end

    it 'not open when answered' do
      subject = build(:answered_pq)
      expect(subject.open?).to be false
    end
  end

  it 'should set pod_waiting when users set draft_answer_received' do
    expect(subject).to receive(:set_pod_waiting)
    subject.update(draft_answer_received: Date.new(2014,9,4))
    subject.save
  end

  it '#set_pod_waiting should work as expected' do
    expect(subject.draft_answer_received).to be_nil
    expect(subject.pod_waiting).to be_nil
    dar = Date.new(2014,9,4)
    subject.draft_answer_received = dar
    subject.set_pod_waiting
    expect(subject.pod_waiting).to eq(dar)
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
      subject.question=nil
      expect(subject).to be_invalid
    end

    it 'should strip any whitespace from uins' do
      subject.update(uin: ' hl1234' )
      expect(subject).to be_valid
      expect(subject.uin).to eql('hl1234')
      subject.update(uin: 'hl1234 ' )
      expect(subject).to be_valid
      expect(subject.uin).to eql('hl1234')
      subject.update(uin: ' hl1 234' )
      expect(subject).to be_valid
      expect(subject.uin).to eql('hl1 234')
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
