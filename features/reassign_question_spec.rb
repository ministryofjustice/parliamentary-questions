require "feature_helper"

describe "Parli-branch re-assigns a question", js: true do
  let(:ao1) { ActionOfficer.find_by(email: "ao1@pq.com") }
  let(:ao2) { ActionOfficer.find_by(email: "ao2@pq.com") }
  let(:dummy_pq) { FactoryBot.create(:pq) }
  let(:minister) { Minister.first }

  it "Parli-branch assigns question to an action officer" do
    create_pq_session
    commission_question(dummy_pq.uin, [ao1], minister)
  end

  it "Parli-branch cannot re-assign before AO accepts question" do
    commission_question(dummy_pq.uin, [ao1], minister)
    create_pq_session
    visit pq_path(dummy_pq.uin)
    click_on "PQ commission"

    expect(page.title).to include("PQ #{dummy_pq.uin}")
    expect(page).not_to have_content("Reassign action officer")
  end

  it "Action officer receive notification and accepts question" do
    commission_question(dummy_pq.uin, [ao1], minister)
    accept_assignment(dummy_pq, ao1)
  end

  it "Parli-branch re-assigns question to another action officer" do
    commission_question(dummy_pq.uin, [ao1], minister)
    accept_assignment(dummy_pq, ao1)
    create_pq_session
    visit pq_path(dummy_pq.uin)
    click_on "PQ commission"

    expect(page).to have_content(ao1.email)
    expect(page).not_to have_content(ao2.email)

    click_on "Manually reject #{ao1.name}"

    commission_question(dummy_pq.uin, [ao2], minister)
    accept_assignment(dummy_pq, ao2)

    visit pq_path(dummy_pq.uin)
    click_on "PQ commission"

    expect(page).not_to have_content(ao1.email)
    expect(page).to have_content(ao2.email)
  end
end
