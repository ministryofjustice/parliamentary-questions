require 'feature_helper'

feature "Watch list member sees allocated questions" do
  before do
    @pq, _ = PQA::QuestionLoader.new.load_and_import
  end

  scenario "Admin creates a new watch list member and sends allocation info. Member accesses watchlist dashboard" do
    include Rails.application.routes.url_helpers

    # Creating a watchlist member
    create_pq_session
    click_link 'Settings'
    click_link 'Watch list'
    click_link_or_button 'Add watchlist member'
    fill_in 'Name', with: 'test-member-a'
    fill_in 'Email', with: 'test-member-a@pq.com'
    click_link_or_button 'Save'
    expect(page).to have_text(/watchlist member was successfully created/i)

    # assign question
    # TODO: This should be done by interacting with the actual UI.
    aos = ActionOfficer.where("email like 'ao%@pq.com'")
    q = Pq.find_by(uin: @pq.uin)

    q.seen_by_finance   = true
    q.minister          = Minister.find_by(name: 'Chris Grayling')
    q.action_officers   = aos
    q.internal_deadline = Date.today + 1.day
    q.internal_deadline = Date.today + 2.day
    PQProgressChangerService.new.update_progress(q)
    q.save
    #

    # sending allocation info
    visit watchlist_members_path
    click_link_or_button 'Send allocation info'

    # assert that the watchlist member receives the email
    mail = ActionMailer::Base.deliveries.last
    expect(mail.cc).to include('test-member-a@pq.com')
    html_email = mail.body.parts.find { |p| p.content_type.match(/text\/html/)}
    doc = Nokogiri::HTML(html_email.body.raw_source)
    watchlist_a = doc.css('a[href^=http]').find { |a| a['href'] =~ Regexp.new(watchlist_dashboard_path) }
    url = watchlist_a['href']
    expect(url).to_not be_blank

    # sign out and visit the watchlist dasboard
    visit destroy_user_session_path
    visit url
    expect(page).to have_text(/allocated today 1/i)
    expect(page).to have_text(@pq.text)

    allocation_el = find('*[data-pqid="1"]')
    aos.each do |action_officer|
      expect(allocation_el).to have_text(action_officer.name)
    end
  end
end
