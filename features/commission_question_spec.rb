require "feature_helper"

describe "Commissioning questions", js: true, suspend_cleaner: true do
  include Features::PqHelpers

  let(:ao)        { ActionOfficer.find_by(email: "ao1@pq.com") }
  let(:ao2)       { ActionOfficer.find_by(email: "ao2@pq.com") }
  let(:minister)  { Minister.second                            }
  let(:test_pq)   { PQA::QuestionLoader.new.load_and_import(2).first }

  before do
    DbHelpers.load_feature_fixtures
  end

  after do
    DatabaseCleaner.clean
  end

  it "Parli-branch member tries to allocate a question without an AO" do
    create_pq_session
    visit dashboard_path

    within_pq(test_pq.uin) do
      select_option("commission_form[minister_id]", minister.name) if minister
      select_option("commission_form[policy_minister_id]", minister.name) if minister
      select ao.name, from: "Action officer(s)"
      find("#internal-deadline input").set Date.tomorrow.strftime("%d/%m/%Y 12:00")
    end

    within("#pq-frame-1") { expect(page).to have_button("Commission") }
    within("#pq-frame-2") { expect(page).not_to have_button("Commission") }
  end

  it "Parli-branch member allocates a question to selected AOs" do
    commission_question(test_pq.uin, [ao, ao2], minister)
  end

  it "AO should receive an email notification of assigned question" do
    pq = Pq.find_by(uin: test_pq.uin)
    ao_mail = NotifyPqMailer.commission_email(pq:, action_officer: ao, token: "1234", entity: "assignment:1", email: ao.email).deliver_now

    expect(ao_mail.to).to include ao.email
    expect(ao_mail.govuk_notify_response.content["body"]).to include "your team is responsible for answering PQ #{test_pq.uin}"
  end

  it "Following the email link should let the AO accept the question" do
    visit_assignment_url(test_pq, ao)
    choose "Accept"
    click_on "Save"

    expect(page).to have_title("PQ assigned")
    expect(page).to have_content(/thank you for your response/i)
    expect(page).to have_content("PQ #{test_pq.uin}")
  end

  it "The PQ status should then change to draft pending" do
    create_pq_session

    expect_pq_in_progress_status(test_pq.uin, "Draft Pending")
  end

  it "The AO should receive an email notification confirming the question acceptance" do
    pq = Pq.find_by(uin: test_pq.uin)
    ao_mail = NotifyPqMailer.acceptance_email(pq:, action_officer: ao, email: ao.email).deliver_now

    expect(ao_mail.to).to include ao.email
    expect(ao_mail.govuk_notify_response.content["body"]).to include("Thank you for agreeing to draft an answer to PQ #{test_pq.uin}")
  end

  it "After an AO has accepted a question, another AO cannot accept the question" do
    visit_assignment_url(test_pq, ao2)

    expect(page).to have_title("PQ assignment")
    expect(page).to have_content(/this pq has already been accepted/i)
    expect(page).to have_content("#{ao.name} accepted PQ #{test_pq.uin}")
  end

  it "Following the link after 3 days have passed should show an error page" do
    pq = Pq.last
    form_params = {
      pq_id: pq.id,
      minister_id: minister.id,
      action_officer_id: [ao.id],
      date_for_answer: Date.tomorrow,
      internal_deadline: Time.zone.today,
    }

    form = CommissionForm.new(form_params)
    CommissioningService.new(nil, Time.zone.today - 4.days).commission(form)

    visit_assignment_url(pq, ao)

    expect(page).to have_title("Unauthorised (401)")
    expect(page).to have_content(/Link expired/i)
  end
end
