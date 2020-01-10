require 'feature_helper'
require 'business_time'

feature 'Early bird member sees allocated questions', suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    @aos  = ActionOfficer.where("email like 'ao%@pq.com'")
    @pq   = generate_dummy_pq(@aos)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario 'An admin can create a new early bird member' do
    create_pq_session
    click_link 'Settings'
    click_link 'Early bird list'
    click_link_or_button 'Add early bird member'
    fill_in 'Name', with: 'test-member-a'
    fill_in 'Email', with: 'test-member-a@pq.com'
    click_link_or_button 'Save'

    expect(page).to have_text(/Early bird member was successfully created/i)
  end

  scenario 'Early bird members can view the new questions for today' do
    create_pq_session
    # '/early_bird/preview'
    visit early_bird_preview_path

    expect(page).to have_text(/1 new parliamentary questions/i)
  end

  scenario 'An admin can trigger an email notification to the early bird members with a link to the daily question list' do
    create_pq_session
    visit early_bird_members_path
    click_link_or_button 'Send early bird info'
    expect(page).to have_text('An email with the new questions information has been sent to all of the early bird members')
  end

  scenario 'A early bird member follows an email link to view the list of daily questions' do
    visit_earlybird_url

    expect(page).to have_text(/1 new parliamentary questions/i)
    expect(page).to have_text(@pq.question)
    expect(page).to have_content("uin-#{@pq.uin}")
  end

  scenario 'The URL token sent to the early bird member expires after 24 hours' do
    two_days_ago = DateTime.now - 2.days
    EarlyBirdReportService.new(nil, two_days_ago).notify_early_bird

    visit_earlybird_url(two_days_ago.end_of_day)

    expect(page).to have_text(/Link expired/i)
  end

  private

  def generate_dummy_pq(_aos)
    PQA::QuestionLoader.new.load_and_import

    q                   = Pq.first
    q.uin               = '1'
    q.minister          = Minister.find_by(name: 'Chris Grayling')
    q.internal_deadline = Time.zone.today + 1.day
    q.internal_deadline = Time.zone.today + 2.days
    q.update_state!
    q
  end
end
