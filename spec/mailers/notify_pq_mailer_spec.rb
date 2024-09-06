require "rails_helper"
describe NotifyPqMailer, type: :mailer do
  let(:pq)    { create :pq }
  let(:ao)    { create :action_officer }

  describe "acceptance_email" do
    let(:mail) { described_class.acceptance_email(pq:, action_officer: ao, email: ao.email) }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "b8b325ad-a00a-4ae9-8830-6386f04adbca"
    end

    it "sets the To address of the email using the provided user" do
      expect(mail.to).to eq([ao.email])
    end

    context "when optional variables are not set" do
      it "sets the personalisation in the email" do
        expect(mail.govuk_notify_personalisation)
          .to eq(
            uin: pq.uin,
            ao_name: ao.name,
            question: pq.question,
            member_name: "Asked by Diana Johnson",
            house_name: "",
            member_constituency: "",
            answer_by: "",
            internal_deadline: "",
            date_to_parliament: "",
            cc_list: "#{ao.email}, pqs@justice.gov.uk",
            mail_reply_to: "pqs@justice.gov.uk",
          )
      end
    end

    context "when optional variables are all set" do
      it "sets the personalisation in the email" do
        minister = FactoryBot.create(:minister)
        pq.update!(member_constituency: "Kingston upon Hull North",
                   member_name: "Diana Johnson",
                   house_name: "House of Commons",
                   minister:)
        ao.update!(group_email: "kulsgroupmail@digital.justice.gov.uk")
        expect(mail.govuk_notify_personalisation)
          .to eq(
            uin: pq.uin,
            ao_name: ao.name,
            question: pq.question,
            member_name: "Asked by Diana Johnson",
            house_name: "House of Commons",
            member_constituency: "Constituency Kingston upon Hull North",
            answer_by: minister.name,
            internal_deadline: "",
            date_to_parliament: "",
            cc_list: "#{ao.email}, pqs@justice.gov.uk",
            mail_reply_to: "pqs@justice.gov.uk",
          )
      end
    end

    it "sets the personalisation keys" do
      expect(mail.govuk_notify_personalisation.keys.sort)
        .to eq(%i[
          answer_by
          ao_name
          cc_list
          date_to_parliament
          house_name
          internal_deadline
          mail_reply_to
          member_constituency
          member_name
          question
          uin
        ])
    end
  end

  describe "acceptance_reminder_email" do
    let(:mail) { described_class.acceptance_reminder_email(pq:, action_officer: ao, email: ao.email) }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "930fb678-0ecf-477c-9d2e-c63e101fcbc4"
    end

    it "sets the To address of the email using the provided user" do
      expect(mail.to).to eq([ao.email])
    end

    context "when optional variables are not set" do
      it "sets the personalisation in the email" do
        expect(mail.govuk_notify_personalisation)
          .to eq(
            uin: pq.uin,
            ao_name: ao.name,
            question: pq.question,
            member_name: "Asked by Diana Johnson",
            house_name: "",
            member_constituency: "",
            answer_by: "",
            internal_deadline: "",
            date_to_parliament: "",
            mail_reply_to: "pqs@justice.gov.uk",
          )
      end
    end

    context "when optional variables are all set" do
      it "sets the personalisation in the email" do
        minister = FactoryBot.create(:minister)
        pq.update!(member_constituency: "Kingston upon Hull North",
                   member_name: "Diana Johnson",
                   house_name: "House of Commons",
                   minister:)
        ao.update!(group_email: "kulsgroupmail@digital.justice.gov.uk")
        expect(mail.govuk_notify_personalisation)
          .to eq(
            uin: pq.uin,
            ao_name: ao.name,
            question: pq.question,
            member_name: "Asked by Diana Johnson",
            house_name: "House of Commons",
            member_constituency: "Constituency Kingston upon Hull North",
            answer_by: minister.name,
            internal_deadline: "",
            date_to_parliament: "",
            mail_reply_to: "pqs@justice.gov.uk",
          )
      end
    end

    it "sets the personalisation keys" do
      expect(mail.govuk_notify_personalisation.keys.sort)
        .to eq(%i[
          answer_by
          ao_name
          date_to_parliament
          house_name
          internal_deadline
          mail_reply_to
          member_constituency
          member_name
          question
          uin
        ])
    end
  end

  describe "commission_email" do
    let(:mail) { described_class.commission_email(pq:, action_officer: ao, token: "token", entity: "entity", email: ao.email) }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "93cb8968-bd2a-401b-8b59-47f8e0b30ca0"
    end

    it "sets the To address of the email using the provided user" do
      expect(mail.to).to eq([ao.email])
    end

    it "sets the personalisation keys" do
      expect(mail.govuk_notify_personalisation.keys.sort)
        .to eq(%i[
          answer_by
          ao_name
          date_to_parliament
          house_name
          internal_deadline
          mail_reply_to
          member_constituency
          member_name
          pq_link
          question
          uin
        ])
    end
  end

  describe "draft_reminder_email" do
    let(:mail) { described_class.draft_reminder_email(pq:, action_officer: ao, email: ao.email) }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "a194ce43-dfe4-4a4f-8f15-8ad2545c4fb9"
    end

    it "sets the To address of the email using the provided user" do
      expect(mail.to).to eq([ao.email])
    end

    it "sets the personalisation keys" do
      expect(mail.govuk_notify_personalisation.keys.sort)
        .to eq(%i[
          answer_by
          ao_name
          cc_list
          date_to_parliament
          house_name
          internal_deadline
          mail_reply_to
          member_constituency
          member_name
          press_email
          question
          uin
        ])
    end
  end

  describe "early_bird_email" do
    let(:mail) { described_class.early_bird_email(email: "early_bird_email", token: "token", entity: "entity") }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "e0700ef3-8a63-4041-ae97-323a1e62272f"
    end

    it "sets the To address of the email using the provided user" do
      expect(mail.to).to eq(%w[early_bird_email])
    end

    it "sets the personalisation keys" do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq(%i[early_bird_link formatted_date reply_to_email])
    end
  end

  describe "watchlist_email" do
    let(:mail) { described_class.watchlist_email(email: "watchlist_email", token: "token", entity: "entity") }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "b452ebb8-c49e-46f6-9da5-3ba28b494ed6"
    end

    it "sets the To address of the email using the provided user" do
      expect(mail.to).to eq(%w[watchlist_email])
    end

    it "sets the personalisation keys" do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq(%i[date_today mail_reply_to watch_list_url])
    end
  end
end
