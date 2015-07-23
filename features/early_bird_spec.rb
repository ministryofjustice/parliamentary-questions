require 'feature_helper'

feature "Early bird member sees allocated questions", suspend_cleaner: true do
  include Features::EmailHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    clear_sent_mail
    @aos  = ActionOfficer.where("email like 'ao%@pq.com'") 
    @pq   = generate_dummy_pq(@aos)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario "An admin can create a new early bird member" do
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
    visit early_bird_dashboard_path #'/early_bird/preview' 

    expect(page).to have_text(/1 new parliamentary questions/i)
  end

  scenario "An admin can trigger an email notification to the early bird members with a link to the daily question list" do
    create_pq_session
    visit early_bird_members_path
    click_link_or_button 'Send early bird info'
    mail = sent_mail.last
    url  = extract_url_like(early_bird_dashboard_path, mail)

    expect(mail.cc).to include('test-member-a@pq.com')
    expect(url).to_not be_blank
  end 

  scenario "A early bird member follows an email link to view the list of daily questions" do
    url = extract_url_like(early_bird_dashboard_path, sent_mail.last)
    visit url
    expect(page).to have_text(/allocated today 1/i)
    expect(page).to have_text(@pq.question)
    allocation_el = find("*[data-pquin='#{@pq.uin}']")

    @aos.each do |action_officer|
      expect(allocation_el).to have_text(action_officer.name)
    end
  end

  scenario 'The URL token sent to the early bird member expires after 24 hours' do
    EarlyBirdReportService.new(nil, DateTime.now - 2.days).notify_earlybird
    url = extract_url_like(early_bird_dashboard_path, sent_mail.last)
    visit url

    expect(page).to have_text(/Link expired/i)
  end

  private

  def generate_dummy_pq(aos)
    PQA::QuestionLoader.new.load_and_import

    q = Pq.first
    q.seen_by_finance   = true
    q.minister          = Minister.find_by(name: 'Chris Grayling')
    #q.action_officers   = aos
    q.internal_deadline = Date.today + 1.day
    q.internal_deadline = Date.today + 2.day
    q.update_state!

    q
  end
end
