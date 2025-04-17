require "feature_helper"

describe "Commissioning questions", :js do
  let(:ao) { ActionOfficer.find_by(email: "ao1@pq.com") }
  let(:ao2) { ActionOfficer.find_by(email: "ao2@pq.com") }
  let(:minister) { Minister.first }
  let(:test_pq) { FactoryBot.create(:pq) }

  before do
    DbHelpers.load_fixtures(:action_officers, :ministers)
  end

  it "Parli-branch member tries to allocate a question without an AO", skip: "temporarly suspending test due to a breaking chromedriver change" do
    PQA::QuestionLoader.new.load_and_import(2)
    pq1 = Pq.first
    pq2 = Pq.second

    create_pq_session
    visit dashboard_path

    within_pq(pq1.uin) do
      select_option("commission_form[minister_id]", minister.name) if minister
      select_option("commission_form[policy_minister_id]", minister.name) if minister
      select ao.name, from: "Action officer(s)"
      find("#internal-deadline input").set Date.tomorrow.strftime("%d/%m/%Y 12:00")
      find(".pq-question").click
    end

    within("#pq-frame-#{pq1.id}") { expect(page).to have_button("Commission") }
    within("#pq-frame-#{pq2.id}") { expect(page).not_to have_button("Commission") }
  end

  it "Parli-branch member allocates a question to selected AOs", skip: "temporarly suspending test due to a breaking chromedriver change" do
    commission_question(test_pq.uin, [ao, ao2], minister)
  end

  it "AO should receive an email notification of assigned question", skip: "temporarly suspending test due to a breaking chromedriver change" do
    ao_mail = NotifyPqMailer.commission_email(pq: test_pq, action_officer: ao, token: "1234", entity: "assignment:1", email: ao.email).deliver_now

    expect(ao_mail.to).to include ao.email
    expect(ao_mail.govuk_notify_response.content["body"]).to include "your team is responsible for answering PQ #{test_pq.uin}"
  end

  it "Following the email link should let the AO accept the question", skip: "temporarly suspending test due to a breaking chromedriver change" do
    commission_question(test_pq.uin, [ao, ao2], minister)
    visit_assignment_url(test_pq, ao)
    choose "Accept"
    click_on "Save"

    expect(page).to have_title("PQ assigned")
    expect(page).to have_content(/thank you for your response/i)
    expect(page).to have_content("PQ #{test_pq.uin}")

    expect_pq_in_progress_status(test_pq.uin, "Draft Pending")
  end

  it "The AO should receive an email notification confirming the question acceptance", skip: "temporarly suspending test due to a breaking chromedriver change" do
    ao_mail = NotifyPqMailer.acceptance_email(pq: test_pq, action_officer: ao, email: ao.email).deliver_now

    expect(ao_mail.to).to include ao.email
    expect(ao_mail.govuk_notify_response.content["body"]).to include("Thank you for agreeing to draft an answer to PQ #{test_pq.uin}")
  end

  it "After an AO has accepted a question, another AO cannot accept the question", skip: "temporarly suspending test due to a breaking chromedriver change" do
    commission_question(test_pq.uin, [ao, ao2], minister)
    visit_assignment_url(test_pq, ao)
    choose "Accept"
    click_on "Save"

    visit_assignment_url(test_pq, ao2)

    expect(page).to have_title("PQ assignment")
    expect(page).to have_content(/this pq has already been accepted/i)
    expect(page).to have_content("#{ao.name} accepted PQ #{test_pq.uin}")
  end

  it "Following the link after 3 days have passed should show an error page", skip: "temporarly suspending test due to a breaking chromedriver change" do
    form_params = {
      pq_id: test_pq.id,
      minister_id: minister.id,
      action_officer_id: [ao.id],
      date_for_answer: Date.tomorrow,
      internal_deadline: Time.zone.today,
    }

    form = CommissionForm.new(form_params)
    CommissioningService.new(nil, Time.zone.today - 4.days).commission(form)

    visit_assignment_url(test_pq, ao)

    expect(page).to have_title("Unauthorised (401)")
    expect(page).to have_content(/Link expired/i)
  end
end
