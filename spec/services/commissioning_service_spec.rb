require 'spec_helper'

describe CommissioningService do
  let(:pq) {
    DBHelpers.pqs.first
  }

  let(:minister) {
    DBHelpers.ministers[0]
  }
  let(:policy_minister) {
    DBHelpers.ministers[1]
  }

  let(:ao1) {
    DBHelpers.action_officers[0]
  }

  let(:ao2) {
    DBHelpers.action_officers[1]
  }

  let(:form_params) {{
    pq_id: pq.id,
    minister_id: minister.id,
    policy_minister_id: policy_minister.id,
    action_officer_id: [ao1.id, ao2.id],
    date_for_answer: Date.tomorrow,
    internal_deadline: Date.today
  }}

  let(:invalid_form_params) {
    form_params.merge(date_for_answer: nil)
  }

  let(:form) {
    CommissionForm.new(form_params)
  }

  let(:invalid_form) {
    CommissionForm.new(invalid_form_params)
  }


  describe "#commission" do
    context "when the supplied form data is not valid" do
      it "raises an error" do
        expect {
          invalid_form = CommissionForm.new(invalid_form_params)
          CommissioningService.new.commission(invalid_form)
        }.to raise_error(ArgumentError)
      end
    end

    context "when the supplied data is valid" do
      before do
        valid_form = CommissionForm.new(form_params)
        @pq        = CommissioningService.new.commission(valid_form)
      end

      it "returns an updated PQ" do
        expect(@pq).to be_valid
        expect(@pq.minister).to eq(minister)
        expect(@pq.policy_minister).to eq(policy_minister)
        expect(@pq.internal_deadline).to eq(form.internal_deadline)
        expect(@pq.date_for_answer).to eq(form.date_for_answer)
      end

      it "sets the pqs' action officers" do
        expect(@pq.action_officers).to eq([
          ao1,
          ao2
        ])
      end

      it "notifies the action officers" do
        MailWorker.new.run!
        ao1_mail, _,  ao2_mail, _ = ActionMailer::Base.deliveries

        expect(ao1_mail.to).to eq([ao1.email])
        expect(ao1_mail.subject).to match(/you have been allocated PQ #{pq.uin}/i)

        expect(ao2_mail.to).to eq([ao2.email])
        expect(ao2_mail.subject).to match(/you have been allocated PQ #{pq.uin}/i)
      end

      it "notifies the deputy director" do
        MailWorker.new.run!
        _, dd1_mail, _, dd2_mail = ActionMailer::Base.deliveries

        expect(dd1_mail.to).to eq([ao1.deputy_director.email])
        expect(dd1_mail.subject).to match(/#{ao1.name} has been allocated PQ #{pq.uin}/i)

        expect(dd2_mail.to).to eq([ao2.deputy_director.email])
        expect(dd2_mail.subject).to match(/#{ao2.name} has been allocated PQ #{pq.uin}/i)
      end

      it "sets the PQ state to 'no-response'" do
        expect(@pq.state).to eq(PQState::NO_RESPONSE)
      end
    end
  end
end
