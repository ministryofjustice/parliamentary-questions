# == Schema Information
#
# Table name: pqs
#
#  id                            :integer          not null, primary key
#  house_id                      :integer
#  raising_member_id             :integer
#  tabled_date                   :datetime
#  response_due                  :datetime
#  question                      :text
#  answer                        :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  uin                           :string
#  member_name                   :string
#  member_constituency           :string
#  house_name                    :string
#  date_for_answer               :date
#  registered_interest           :boolean
#  internal_deadline             :datetime
#  question_type                 :string
#  minister_id                   :integer
#  policy_minister_id            :integer
#  progress_id                   :integer
#  draft_answer_received         :datetime
#  holding_reply                 :datetime
#  preview_url                   :string
#  pod_waiting                   :datetime
#  pod_clearance                 :datetime
#  transferred                   :boolean
#  question_status               :string
#  sent_to_policy_minister       :datetime
#  cleared_by_policy_minister    :datetime
#  sent_to_answering_minister    :datetime
#  cleared_by_answering_minister :datetime
#  answer_submitted              :datetime
#  final_response_info_released  :string
#  transfer_out_ogd_id           :integer
#  transfer_out_date             :datetime
#  directorate_id                :integer
#  original_division_id          :integer
#  transfer_in_ogd_id            :integer
#  transfer_in_date              :datetime
#  state                         :string           default("unassigned")
#  state_weight                  :integer          default(0)
#  archived                      :boolean          default(FALSE)
#

require "rails_helper"

describe Pq do
  subject(:question) { build(:pq) }

  describe "associations" do
    it { is_expected.to belong_to :minister }
    it { is_expected.to belong_to :policy_minister }
    it { is_expected.to belong_to :directorate }
    it { is_expected.to belong_to :original_division }
  end

  describe ".before_update" do
    it "sets the state weight" do
      state = PqState::DRAFT_PENDING
      pq, = DbHelpers.pqs
      pq.update!(state:)
      expect(pq.state_weight).to eq(PqState.state_weight(state))
    end
  end

  describe "scopes" do
    describe ".unarchived" do
      it "only returns questions that have not been archived" do
        create_list(:pq, 2, archived: true)
        unarchived = create_list(:pq, 2, archived: false)

        expect(described_class.unarchived).to match unarchived
      end
    end
  end

  describe ".sorted_for_dashboard" do
    it "sorts pqs in the expected order" do
      # Start with randomly ordered PQs
      pqs = DbHelpers.pqs(8).shuffle

      # Update to cover all sorting criteria
      pqs[0].update!(date_for_answer: Date.tomorrow, state: PqState::POD_CLEARED)
      pqs[1].update!(date_for_answer: Date.tomorrow)
      pqs[2].update!(date_for_answer: Date.tomorrow  + 1.day, state: PqState::POD_CLEARED)
      pqs[3].update!(date_for_answer: Date.tomorrow  + 1.day)
      pqs[4].update!(date_for_answer: Date.yesterday, state: PqState::POD_CLEARED)
      pqs[5].update!(date_for_answer: Date.yesterday)
      pqs[6].update!(date_for_answer: Date.yesterday - 1.day, state: PqState::WITH_MINISTER)
      pqs[7].update(date_for_answer: Date.yesterday - 1.day) && pqs[7]

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

      expect(described_class.sorted_for_dashboard.map(&:uin)).to eq([
        on_time_due_sooner_higher_weight,
        on_time_due_sooner_lower_weight,
        on_time_due_later_higher_weight,
        on_time_due_later_lower_weight,
        late_due_sooner_higher_weight,
        late_due_sooner_lower_weight,
        late_due_later_higher_weight,
        late_due_later_lower_weight,
      ].map(&:uin))
    end
  end

  describe "allocated_since" do
    subject(:allocated_question) { described_class.allocated_since(Time.zone.now) }

    it "returns questions allocated from given time and ordered by uin" do
      @older_pq = create(:not_responded_pq, action_officer_allocated_at: Time.zone.now - 2.days)
      @new_pq1 = create(:not_responded_pq, uin: "20001", action_officer_allocated_at: Time.zone.now + 3.hours)
      @new_pq2 = create(:not_responded_pq, uin: "HL03",  action_officer_allocated_at: Time.zone.now + 5.hours)
      @new_pq3 = create(:not_responded_pq, uin: "15000", action_officer_allocated_at: Time.zone.now + 5.hours)

      expect(allocated_question.length).to be(3)
      expect(allocated_question.map(&:uin)).to eql(%w[15000 20001 HL03])
    end
  end

  describe "association methods" do
    let!(:accepted) { create(:accepted_action_officers_pq, pq: subject) }
    let!(:awaiting) { create(:action_officers_pq, pq: subject) }

    before do
      2.times { create(:rejected_action_officers_pq, pq: question) }
    end

    describe "#action_officers_pq" do
      describe "#accepted" do
        it "returns 1 record" do
          expect(question.action_officers_pqs.accepted).to eq accepted
        end
      end

      describe "#rejected" do
        it "returns 2 records" do
          expect(question.action_officers_pqs.rejected.count).to eq 2
        end
      end

      describe "#not_rejected" do
        it "returns 2 records" do
          expect(question.action_officers_pqs.not_rejected.count).to eq 2
        end
      end

      describe "#all_rejected?" do
        it "returns true when all action officers have rejected" do
          accepted.reject(nil, nil)
          awaiting.reject(nil, nil)
          expect(question.action_officers_pqs).to be_all_rejected
        end

        it "returns false when an action officer has not responded" do
          accepted.reject(nil, nil)
          expect(question.action_officers_pqs).not_to be_all_rejected
        end

        it "returns false when an action officer has accepted" do
          awaiting.reject(nil, nil)
          expect(question.action_officers_pqs).not_to be_all_rejected
        end
      end
    end

    describe "#action_officers" do
      describe "#accepted" do
        it "returns 1 record" do
          expect(question.action_officers.accepted).to eq accepted.action_officer
        end
      end

      describe "#rejected" do
        it "returns 2 records" do
          expect(question.action_officers.rejected.count).to eq 2
        end
      end

      describe "#not_rejected" do
        it "returns 2 records" do
          expect(question.action_officers.not_rejected.count).to eq 2
        end
      end
    end
  end

  describe "#reassign" do
    subject(:reassigned_question) { create(:draft_pending_pq) }

    let!(:original_assignment) { subject.ao_pq_accepted }
    let(:new_assignment) { create :action_officers_pq, pq: subject }
    let(:new_action_officer) { new_assignment.action_officer }
    let(:division) { new_action_officer.deputy_director.division }
    let(:directorate) { division.directorate }

    before do
      reassigned_question.action_officers << new_action_officer
    end

    it "assigns a new action officer" do
      reassigned_question.reassign new_action_officer

      expect(original_assignment.reload.response).to eq :awaiting
      expect(new_assignment.reload).to be_accepted
      expect(reassigned_question.original_division).to eq(division)
      expect(reassigned_question.directorate).to eq(directorate)
    end

    context "when reassigning to an action officer already commissioned (in the list)" do
      it "assigns to other action officer" do
        reassigned_question.action_officers_pqs << new_assignment
        reassigned_question.reassign new_action_officer

        expect(original_assignment.reload.response).to eq :awaiting
        expect(new_assignment.reload).to be_accepted
      end
    end

    context "when nil" do
      it "ignores change" do
        expect(reassigned_question).not_to receive(:action_officers_pqs) # rubocop:disable RSpec/SubjectStub
        reassigned_question.reassign nil
      end
    end
  end

  describe "#commissioned?" do
    subject(:commissioned_question) { create(:pq) }

    context "when no officer is assigned" do
      it { is_expected.not_to be_commissioned }
    end

    context "when all assigned officers are rejected" do
      before do
        commissioned_question.action_officers_pqs.create(action_officer: create(:action_officer), response: "rejected")
      end

      it { is_expected.not_to be_commissioned }
    end

    context "when some assigned officers are not rejected" do
      before do
        commissioned_question.action_officers_pqs.create!(action_officer: create(:action_officer))
        commissioned_question.action_officers_pqs.create!(action_officer: create(:action_officer), response: "rejected")
        commissioned_question.internal_deadline = Time.zone.today
      end

      it { is_expected.to be_commissioned }
    end
  end

  describe "#proposed?" do
    subject(:proposed_question) { create(:pq) }

    context "when no officer is assigned" do
      it { is_expected.not_to be_proposed }
    end

    context "when an action officer is proposed" do
      before do
        proposed_question.action_officers_pqs.create(action_officer: create(:action_officer))
      end

      it { is_expected.to be_proposed }
    end
  end

  describe "#closed?" do
    it "is closed when answered" do
      subject = build(:answered_pq)
      expect(subject.closed?).to be true
    end

    it "is not closed when unanswered" do
      subject = build(:pq)
      expect(subject.closed?).to be false
    end
  end

  describe "#open?" do
    it "open when unanswered" do
      subject = build(:pq)
      expect(subject.open?).to be true
    end

    it "not open when answered" do
      subject = build(:answered_pq)
      expect(subject.open?).to be false
    end
  end

  it "sets pod_waiting when users set draft_answer_received" do
    expect(question).to receive(:set_pod_waiting) # rubocop:disable RSpec/SubjectStub
    question.update!(draft_answer_received: Date.new(2014, 9, 4))
    question.save!
  end

  it "#set_pod_waiting should work as expected" do
    expect(question.draft_answer_received).to be_nil
    expect(question.pod_waiting).to be_nil
    dar = Date.new(2014, 9, 4)
    question.draft_answer_received = dar
    question.set_pod_waiting
    expect(question.pod_waiting).to eq(dar)
  end

  describe "validation" do
    let(:pq) do
      pq = FactoryBot.create(:pq)
      3.times do
        ao = FactoryBot.create(:action_officer)
        pq.action_officers << ao
      end
      pq.save!
      pq
    end

    it "passes onfactory build" do
      expect(pq).to be_valid
    end

    it "has a Uin" do
      pq.uin = nil
      expect(pq).to be_invalid
    end

    it "has a Raising MP ID" do
      pq.raising_member_id = nil
      expect(pq).to be_invalid
    end

    it "has text" do
      pq.question = nil
      expect(pq).to be_invalid
    end

    it "strips any whitespace from uins" do
      pq.update!(uin: " hl1234")
      expect(pq).to be_valid
      expect(pq.uin).to eql("hl1234")
      pq.update!(uin: "hl1234 ")
      expect(pq).to be_valid
      expect(pq.uin).to eql("hl1234")
      pq.update!(uin: " hl1 234")
      expect(pq).to be_valid
      expect(pq.uin).to eql("hl1 234")
    end

    context "multiple action officers"

    it "is valid if none accepted" do
      expect(pq.action_officers_pqs.map(&:response)).to eq(%i[awaiting awaiting awaiting])
      expect(pq).to be_valid
    end

    it "is valid if only one accepted" do
      aopq = pq.action_officers_pqs.first
      aopq.response = :accepted
      aopq.save!

      expect(pq.action_officers_pqs.order(:id).map(&:response)).to eq(%i[accepted awaiting awaiting])
      expect(pq).to be_valid
    end

    it "is not valid if multiple accepted but only one of those is active" do
      ao1 = pq.action_officers.order(:id).first
      ao1.deleted = true
      ao1.save!
      ao2 = pq.action_officers.order(:id)[1]
      ao2.deleted = true
      ao2.save!
      pq.action_officers_pqs.each do |aopq|
        aopq.response = :accepted
        aopq.save!
      end
      expect(pq.action_officers.order(:id).map(&:deleted)).to eq([true, true, false])
      expect(pq.action_officers_pqs.order(:id).map(&:response)).to eq(%i[accepted accepted accepted])
      expect(pq).not_to be_valid
      expect(pq.errors[:base]).to eq(["Unable to have two action officers accepted on the same question"])
    end

    it "is not valid if multiple accepted active" do
      pq.action_officers_pqs.each do |aopq|
        aopq.response = :accepted
        aopq.save!
      end
      expect(pq.action_officers.order(:id).map(&:deleted)).to eq([false, false, false])
      expect(pq.action_officers_pqs.order(:id).map(&:response)).to eq(%i[accepted accepted accepted])
      expect(pq).not_to be_valid
      expect(pq.errors[:base]).to eq(["Unable to have two action officers accepted on the same question"])
    end
  end
end
