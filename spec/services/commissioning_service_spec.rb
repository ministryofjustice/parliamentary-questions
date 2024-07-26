require "rails_helper"

describe CommissioningService do
  shared_context "with test_values" do
    let(:ao1)                 { DbHelpers.action_officers[0] }
    let(:ao2)                 { DbHelpers.action_officers[1] }
    let(:form)                { CommissionForm.new(form_params) }
    let(:invalid_form_params) { form_params.merge(date_for_answer: nil) }
    let(:invalid_form)        { CommissionForm.new(invalid_form_params) }
    let(:minister)            { DbHelpers.ministers[0] }
    let(:policy_minister)     { DbHelpers.ministers[1] }
    let(:pq)                  { DbHelpers.pqs.first }
    let(:form_params)         do
      {
        pq_id: pq.id,
        minister_id: minister.id,
        policy_minister_id: policy_minister.id,
        action_officer_id: [ao1.id, ao2.id],
        date_for_answer: Date.tomorrow,
        internal_deadline: Time.zone.today.midnight,
      }
    end
  end

  describe "#commission" do
    include_context "with test_values"
    context "when the supplied form data is not valid" do
      it "raises an error" do
        expect {
          invalid_form = CommissionForm.new(invalid_form_params)
          described_class.new.commission(invalid_form)
        }.to raise_error(ArgumentError)
      end
    end

    context "when the supplied data is valid" do
      # rubocop:disable RSpec/InstanceVariable
      before do
        allow(NotifyPqMailer).to receive_message_chain(:commission_email, :deliver_later) # rubocop:disable RSpec/MessageChain
        valid_form = CommissionForm.new(form_params)
        @pq = described_class.new.commission(valid_form)
      end

      it "returns an updated PQ" do
        expect(@pq).to be_valid
        expect(@pq.minister).to eq(minister)
        expect(@pq.policy_minister).to eq(policy_minister)
        expect(@pq.internal_deadline.to_s).to eq(form.internal_deadline.to_s)
        expect(@pq.date_for_answer).to eq(form.date_for_answer)
      end

      it "sets the pqs' action officers" do
        expect(@pq.action_officers).to eq([ao1, ao2])
      end

      it "notifies both of the action officers" do
        expect(NotifyPqMailer).to have_received(:commission_email).with(hash_including(pq:, action_officer: ao1))
        expect(NotifyPqMailer).to have_received(:commission_email).with(hash_including(pq:, action_officer: ao2))
      end

      it "sets the PQ state to 'no-response'" do
        expect(@pq.state).to eq(PqState::NO_RESPONSE)
      end
      # rubocop:enable RSpec/InstanceVariable
    end

    context "when there are three action officers to choose from" do
      # commission pq in normal state arrived from parli
      # gives two action officers
      # expects to see those 2 action officer

      # create a third officer
      # create a proposed pq that has one ao
      # run through the commissioning service

      let(:ao3) { DbHelpers.action_officers[2] }
      let(:valid_form) { CommissionForm.new(form_params) }
      let(:commission) { described_class.new.commission(valid_form) }

      before do
        commission.action_officers << ao3
      end

      it "sets the pqs' action officers" do
        expect(commission.action_officers).to eq([ao1, ao2, ao3])
      end
    end
  end
end
