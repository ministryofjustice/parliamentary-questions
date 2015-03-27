require 'feature_helper'

feature 'Parli-branch manually rejecting and re-assigning OAs', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures

    clear_sent_mail
    @pq, _ =  PQA::QuestionLoader.new.load_and_import(2)
    set_seen_by_finance
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  let(:ao1)             { ActionOfficer.find_by(email: 'ao1@pq.com') }
  let(:ao2)             { ActionOfficer.find_by(email: 'ao2@pq.com') }
  let(:ao3)             { ActionOfficer.find_by(email: 'ao3@pq.com') }
  let(:minister)        { Minister.first                             }
  let(:policy_minister) { Minister.limit(2)[1]                       }

  def selected_option_text(field_name)
    find("select[name='#{field_name}'] option[selected='selected']").text
  end

  scenario "PB commissions a question to two AOs" do
    commission_question(@pq.uin, [ao1, ao2], minister, policy_minister)
  end

  scenario "PB manually rejects the first AO" do
    create_pq_session
    visit pq_path(@pq.uin)
    click_on "PQ commission"
    first('a', text:'Manually reject this action officer').click
    expect(page.title).to have_text("PQ #{@pq.uin}")
    expect(page).to have_content("#{@pq.uin} manually rejected")

    visit pq_path(@pq.uin)
    click_on "PQ commission"
    expect(page.title).to have_text("PQ #{@pq.uin}")
    expect(page).to have_content("rejected manually by pq@pq.com")
    expect_pq_status(@pq.uin, "No response")
  end

  scenario "PB manually rejects the last AO" do
    create_pq_session
    visit pq_path(@pq.uin)
    click_on "PQ commission"
    first('a', text:'Manually reject this action officer').click
    expect_pq_status(@pq.uin, "Rejected")

    within_pq(@pq.uin) do
      selected_minister        = selected_option_text('commission_form[minister_id]')
      selected_policy_minister = selected_option_text('commission_form[policy_minister_id]')
      expect(selected_minister).to eq(minister.name)
      expect(selected_policy_minister).to eq(policy_minister.name)
    end
  end
end
