require "feature_helper"

describe "Parli-branch re-assigns a question", :js do
  let(:ao_first) { ActionOfficer.first }
  let(:ao_second) { ActionOfficer.second }
  let(:dummy_pq) { FactoryBot.create(:pq) }
  let(:minister) { Minister.first }

  before do
    DbHelpers.load_fixtures(:action_officers, :ministers)
  end

  it "Parli-branch assigns question to an action officer", skip: "temporarly suspending test due to a breaking chromedriver change" do
    create_pq_session
    commission_question(dummy_pq.uin, [ao_first], minister)
  end

  it "Parli-branch cannot re-assign before AO accepts question", skip: "temporarly suspending test due to a breaking chromedriver change" do
    commission_question(dummy_pq.uin, [ao_first], minister)
    create_pq_session
    visit pq_path(dummy_pq.uin)
    click_on "PQ commission"

    expect(page.title).to include("PQ #{dummy_pq.uin}")
    expect(page).not_to have_content("Reassign action officer")
  end

  it "Action officer receive notification and accepts question", skip: "temporarly suspending test due to a breaking chromedriver change" do
    commission_question(dummy_pq.uin, [ao_first], minister)
    accept_assignment(dummy_pq, ao_first)
  end

  it "Parli-branch re-assigns question to another action officer", skip: "temporarly suspending test due to a breaking chromedriver change" do
    commission_question(dummy_pq.uin, [ao_first], minister)
    accept_assignment(dummy_pq, ao_first)
    create_pq_session
    visit pq_path(dummy_pq.uin)
    click_on "PQ commission"

    expect(page).to have_content(ao_first.email)
    expect(page).not_to have_content(ao_second.email)

    click_on "Manually reject #{ao_first.name}"

    commission_question(dummy_pq.uin, [ao_second], minister)
    accept_assignment(dummy_pq, ao_second)

    visit pq_path(dummy_pq.uin)
    click_on "PQ commission"

    expect(page).not_to have_content(ao_first.email)
    expect(page).to have_content(ao_second.email)
  end
end
