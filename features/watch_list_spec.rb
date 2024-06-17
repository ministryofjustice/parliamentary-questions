require "feature_helper"

describe "Watch list member sees allocated questions", suspend_cleaner: true do
  include Features::PqHelpers

  before do
    DbHelpers.load_feature_fixtures
  end

  after do
    DatabaseCleaner.clean
  end

  let(:dummy_aos) { ActionOfficer.where("email like 'ao%@pq.com'") }
  let(:dummy_pq) { generate_dummy_pq(dummy_aos) }

  it "An admin can create a new watchlist member" do
    create_pq_session
    click_link "Settings"
    click_link "Watch list"
    click_link_or_button "Add watchlist member"
    fill_in "Name", with: "test-member-a"
    fill_in "Email", with: "test-member-a@pq.com"
    click_link_or_button "Save"

    expect(page).to have_text(/watchlist member was successfully created/i)
  end

  it "An admin can trigger an email notification to the watchlist members with a link to the daily question list" do
    create_pq_session
    visit watchlist_members_path
    click_link_or_button "Send allocation info"
    expect(page).to have_text("An email with the allocation information has been sent to all of the watchlist member")
  end

  it "A watchlist member follows an email link to view the list of daily questions" do
    visit_watchlist_url

    expect(page).to have_text(/allocated today 1/i)
    expect(page).to have_text(dummy_pq.question)
    allocation_el = find("*[data-pquin='#{dummy_pq.uin}']")

    dummy_aos.each do |action_officer|
      expect(allocation_el).to have_text(action_officer.name)
    end
  end

  it "The URL token sent to the watchlist member expires after 24 hours" do
    two_days_ago = Time.zone.now - 2.days
    WatchlistReportService.new(nil, two_days_ago).notify_watchlist

    visit_watchlist_url(two_days_ago)
    expect(page).to have_text(/Link expired/i)
  end

private

  def generate_dummy_pq(aos)
    PQA::QuestionLoader.new.load_and_import

    q = Pq.first
    q.minister = Minister.find_by(name: "Chris Grayling")
    q.action_officers = aos
    q.internal_deadline = Time.zone.today + 1.day
    q.internal_deadline = Time.zone.today + 2.days
    q.update_state!
    q
  end
end
