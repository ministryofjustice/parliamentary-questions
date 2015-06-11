# == Schema Information
#
# Table name: pqs
#
#  id                                            :integer          not null, primary key
#  house_id                                      :integer
#  raising_member_id                             :integer
#  tabled_date                                   :datetime
#  response_due                                  :datetime
#  question                                      :text
#  answer                                        :string(255)
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  finance_interest                              :boolean
#  seen_by_finance                               :boolean          default(FALSE)
#  uin                                           :string(255)
#  member_name                                   :string(255)
#  member_constituency                           :string(255)
#  house_name                                    :string(255)
#  date_for_answer                               :date
#  registered_interest                           :boolean
#  internal_deadline                             :datetime
#  question_type                                 :string(255)
#  minister_id                                   :integer
#  policy_minister_id                            :integer
#  progress_id                                   :integer
#  draft_answer_received                         :datetime
#  i_will_write_estimate                         :datetime
#  holding_reply                                 :datetime
#  preview_url                                   :string(255)
#  pod_waiting                                   :datetime
#  pod_query                                     :datetime
#  pod_clearance                                 :datetime
#  transferred                                   :boolean
#  question_status                               :string(255)
#  round_robin                                   :boolean
#  round_robin_date                              :datetime
#  i_will_write                                  :boolean
#  pq_correction_received                        :boolean
#  correction_circulated_to_action_officer       :datetime
#  pod_query_flag                                :boolean
#  sent_to_policy_minister                       :datetime
#  policy_minister_query                         :boolean
#  policy_minister_to_action_officer             :datetime
#  policy_minister_returned_by_action_officer    :datetime
#  resubmitted_to_policy_minister                :datetime
#  cleared_by_policy_minister                    :datetime
#  sent_to_answering_minister                    :datetime
#  answering_minister_query                      :boolean
#  answering_minister_to_action_officer          :datetime
#  answering_minister_returned_by_action_officer :datetime
#  resubmitted_to_answering_minister             :datetime
#  cleared_by_answering_minister                 :datetime
#  answer_submitted                              :datetime
#  library_deposit                               :boolean
#  pq_withdrawn                                  :datetime
#  holding_reply_flag                            :boolean
#  final_response_info_released                  :string(255)
#  round_robin_guidance_received                 :datetime
#  transfer_out_ogd_id                           :integer
#  transfer_out_date                             :datetime
#  directorate_id                                :integer
#  original_division_id                          :integer
#  transfer_in_ogd_id                            :integer
#  transfer_in_date                              :datetime
#  follow_up_to                                  :string(255)
#  state                                         :string(255)      default("unassigned")
#  state_weight                                  :integer          default(0)
#

require 'spec_helper'

describe Pq do
  let(:subject) {build(:pq)}

  describe "associations" do
    it { is_expected.to belong_to :minister }
    it { is_expected.to belong_to :policy_minister }
    it { is_expected.to have_one :trim_link }
    it { is_expected.to belong_to :directorate }
    it { is_expected.to belong_to :original_division }
  end

  describe ".before_update" do
    it "sets the state weight" do
      state    = PQState::DRAFT_PENDING
      pq, _    = DBHelpers.pqs
      pq.update(state: state)
      expect(pq.state_weight).to eq(PQState.state_weight(state))
    end
  end

  describe ".sorted_for_dashboard" do
    it "sorts pqs in the expected order" do
      # Start with randomly ordered PQs
      pqs = DBHelpers.pqs(8).shuffle

      # Update to cover all sorting criteria
      pqs[0].update(date_for_answer: Date.tomorrow, state: PQState::POD_CLEARED)
      pqs[1].update(date_for_answer: Date.tomorrow)
      pqs[2].update(date_for_answer: Date.tomorrow  + 1.days, state: PQState::POD_QUERY)
      pqs[3].update(date_for_answer: Date.tomorrow  + 1.days)
      pqs[4].update(date_for_answer: Date.yesterday, state: PQState::POD_CLEARED)
      pqs[5].update(date_for_answer: Date.yesterday)
      pqs[6].update(date_for_answer: Date.yesterday - 1.days, state: PQState::WITH_MINISTER)
      pqs[7].update(date_for_answer: Date.yesterday - 1.days) && pqs[7]

      # Late PQs are pushed to the bottom regardless
      late_due_sooner_higher_weight = pqs[4]
      late_due_sooner_lower_weight  = pqs[5]
      late_due_later_higher_weight  = pqs[6]
      late_due_later_lower_weight   = pqs[7]

      # PQs sorted by absolute days until date for answer, then state weight
      on_time_due_sooner_higher_weight  = pqs[0]
      on_time_due_sooner_lower_weight   = pqs[1]
      on_time_due_later_higher_weight   = pqs[2]
      on_time_due_later_lower_weight    = pqs[3]

      expect(Pq.sorted_for_dashboard.map(&:uin)).to eq([
        on_time_due_sooner_higher_weight,
        on_time_due_sooner_lower_weight,
        on_time_due_later_higher_weight,
        on_time_due_later_lower_weight,
        late_due_sooner_higher_weight,
        late_due_sooner_lower_weight,
        late_due_later_higher_weight,
        late_due_later_lower_weight
      ].map(&:uin))
    end
  end

  describe ".count_accepted_by_press_desk" do
    def accept_pq(pq, ao)
      pq.action_officers_pqs << ActionOfficersPq.new(action_officer: ao,
                                                     response: 'accepted',
                                                     pq: pq)
      pq.save
    end

    context "when no data exist" do
      it "returns an empty hash" do
        expect(Pq.count_accepted_by_press_desk).to eq({})
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
        expect(Pq.count_accepted_by_press_desk).to eq({
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
          expect(Pq.count_accepted_by_press_desk).to eq({
            PQState::WITH_POD => {
              @pd2.id => 2
            }
          })
        end
      end
    end
  end

  describe ".count_in_progress_by_minister" do
    context "when no data exist" do
      it "returns an empty hash" do
        expect(Pq.count_in_progress_by_minister).to eq({})
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
        expect(Pq.count_in_progress_by_minister).to eq({
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
          expect(Pq.count_in_progress_by_minister).to eq({
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
    def commission_and_accept(pq, ao, minister)
      pq.state    = PQState::WITH_POD
      pq.minister = minister
      pq.action_officers_pqs << ActionOfficersPq.new(pq: pq,
                                                     response: 'accepted',
                                                     action_officer: ao,)
      pq.save
    end

    before do
      @ao1, @ao2             = DBHelpers.action_officers
      @min1, _               = DBHelpers.ministers
      @pq1, @pq2, @pq3, @pq4 = DBHelpers.pqs

      expect(@ao1.press_desk).to_not eq(@ao2.press_desk)
      commission_and_accept(@pq1, @ao1, @min1)
      commission_and_accept(@pq4, @ao2, @min1)
    end

    context "when state, minister or press desk are all nil" do
      it "returns all the records" do
        expect(Pq.filter_for_report(nil, nil, nil).pluck(:uin).to_set).to eq([
          'uin-1', 'uin-2', 'uin-3', 'uin-4'
        ].to_set)
      end
    end
    context "when state, minister or press desk are all present" do
      it "returns the expected records" do
        uins = Pq.filter_for_report(PQState::WITH_POD, @minister, @ao1.press_desk)
                 .pluck(:uin)

        expect(uins).to eq(['uin-1'])
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
      expect(subject.original_division).to eq(division)
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

    context 'multiple action officers'

      let(:pq) do
        pq = FactoryGirl.create(:pq)
        3.times do
          ao = FactoryGirl.create(:action_officer)
          pq.action_officers << ao
        end
        pq.save
        pq
      end

      it 'should be valid if none accepted' do
        expect(pq.action_officers_pqs.map(&:response)).to eq([:awaiting, :awaiting, :awaiting])
        expect(pq).to be_valid
      end

      it 'should be valid if only one accepted' do
        aopq = pq.action_officers_pqs.first
        aopq.response = :accepted
        aopq.save!

        expect(pq.action_officers_pqs.order(:id).map(&:response)).to eq([:accepted, :awaiting, :awaiting])
        expect(pq).to be_valid
      end

      it 'should not be valid if multiple accepted but only one of those is active' do
        ao1 = pq.action_officers.order(:id).first
        ao1.deleted = true
        ao1.save!
        ao2 = pq.action_officers[1]
        ao2.deleted = true
        ao2.save!
        pq.action_officers_pqs.each do |aopq|
          aopq.response = :accepted
          aopq.save!
        end
        expect(pq.action_officers.order(:id).map(&:deleted)).to eq( [ true, true, false ] )
        expect(pq.action_officers_pqs.order(:id).map(&:response)).to eq([:accepted, :accepted, :accepted])
        expect(pq).not_to be_valid
        expect(pq.errors[:base]).to eq([ 'Unable to have two action officers accepted on the same question'])
      end


      it 'should not be valid if multiple accepted active' do
        pq.action_officers_pqs.each do |aopq|
          aopq.response = :accepted
          aopq.save!
        end
        expect(pq.action_officers.order(:id).map(&:deleted)).to eq( [ false, false, false ] )
        expect(pq.action_officers_pqs.order(:id).map(&:response)).to eq([:accepted, :accepted, :accepted])
        expect(pq).not_to be_valid
        expect(pq.errors[:base]).to eq([ 'Unable to have two action officers accepted on the same question'])
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
