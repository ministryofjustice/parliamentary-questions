require "feature_helper"
require "business_time"

describe "Early bird member sees allocated questions" do
  let(:aos)       { ActionOfficer.where("email like 'ao%@pq.com'") }
  let(:dummy_pq)  { generate_dummy_pq(aos) }

  it "An admin can create a new early bird member" do
    create_pq_session
    click_link "Settings"
    click_link "Early bird list"
    click_link_or_button "Add early bird member"
    fill_in "Name", with: "test-member-a"
    fill_in "Email", with: "test-member-a@pq.com"
    click_link_or_button "Save"

    expect(page).to have_text(/Early bird member was successfully created/i)
  end

  it "Early bird members can view the new questions for today" do
    create_pq_session
    # '/early_bird/preview'
    visit early_bird_preview_path

    expect(page).to have_text(/1 new parliamentary questions/i)
  end

  it "An admin can trigger an email notification to the early bird members with a link to the daily question list" do
    create_pq_session
    visit early_bird_members_path
    click_link_or_button "Send early bird info"
    expect(page).to have_text("An email with the new questions information has been sent to all of the early bird members")
  end

  it "A early bird member follows an email link to view the list of daily questions" do
    visit_earlybird_url
    expect(page).to have_text(/1 new parliamentary questions/i)
    expect(page).to have_text(dummy_pq.question)
    expect(page).to have_content("uin-#{dummy_pq.uin}")
    expect(page).to have_link("Email PQ team about this question", href: "mailto:pqs@justice.gov.uk?subject=Question 1")
  end

  it "An early bird member recommends someone to answer" do
    visit_earlybird_url
    expect(page).to have_link("Propose a Deputy Director")
    click_link "Propose a Deputy Director"
    expect(page).to have_content("Propose a Deputy Director")
    select aos.first.name, from: "Deputy Director(s)"
    click_on "Save"
    expect(page).to have_content("Successfully proposed Deputy Director(s)")
    expect(page).to have_content(aos.first.name)
    create_pq_session
    click_on "PQ Tracker"
    expect(page).to have_content(aos.first.name)
    expect(page).to have_content("Action Officer Proposed")
  end

  it "An early bird member sees a question that is commissioned" do
    allow(dummy_pq).to receive(:commissioned?).and_return(true)

    visit_earlybird_url
    expect(page).not_to have_link("Propose a Deputy Director")
  end

  it "The URL token sent to the early bird member expires after 24 hours" do
    two_days_ago = Time.zone.now - 2.days
    EarlyBirdReportService.new(nil, two_days_ago).notify_early_bird

    visit_earlybird_url(two_days_ago)

    expect(page).to have_text(/Link expired/i)
  end

private

  def generate_dummy_pq(_aos)
    PQA::QuestionLoader.new.load_and_import
    q = Pq.first
    q.uin = "1"
    q.minister = Minister.find_by(name: "Chris Grayling")
    q.update_state!
    q
  end
end
