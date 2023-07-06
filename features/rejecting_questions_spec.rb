require "feature_helper"

describe "Rejecting questions", js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    @pq, = PQA::QuestionLoader.new.load_and_import(2)
  end

  after do
    DatabaseCleaner.clean
  end

  let(:ao1)        { ActionOfficer.find_by(email: "ao1@pq.com") }
  let(:ao2)        { ActionOfficer.find_by(email: "ao2@pq.com") }
  let(:minister)   { Minister.first                             }

  it "Parli-branch member allocates a question to selected AOs" do
    commission_question(@pq.uin, [ao1, ao2], minister)
  end

  it "Following the email link should let an AO reject the question" do
    reject_assignment(@pq, ao1, 2, "going to the cinema")
    expect(page.title).to have_text("PQ rejected")
    expect(page).to have_content(/thank you for your response/i)
  end

  it "Parli-branch should see which AOs have rejected the question" do
    create_pq_session
    visit dashboard_path

    within_pq(@pq.uin) do
      expect(page.title).to have_text("Dashboard")
      expect(page).to have_text("#{ao1.name} rejected at:")
      expect(page).to have_text("going to the cinema")
    end
  end

  it "The question status should remain no response" do
    create_pq_session
    expect_pq_status(@pq.uin, "No response")
  end

  it "If an AO submits an empty acceptance form, show an error" do
    visit_assignment_url(@pq, ao2)
    click_on "Save Response"
    expect(page).to have_content("Form was not completed")
    expect(page).not_to have_content("Please select one of the reasons to reject the question")
  end

  it "If an AO rejects without a reason, show an error" do
    create_pq_session
    visit_assignment_url(@pq, ao2)
    choose "Reject"
    click_on "Save Response"
    expect(page).to have_content("Form was not completed")
    expect(page).to have_content("Please select one of the reasons to reject the question")
    expect(page).to have_content("Please give us information about why you reject the question")
  end

  it "If an AO rejects without selecting from the dropdown, show an error" do
    visit_assignment_url(@pq, ao2)
    choose "Reject"
    fill_in "allocation_response_reason", with: "no time"
    click_on "Save Response"
    expect(page).to have_content("Form was not completed")
    expect(page).to have_content("Please select one of the reasons to reject the question")
    expect(page).not_to have_content("Please give us information about why you reject the question")
  end

  it "If an AO rejects without typing a reason, show an error" do
    visit_assignment_url(@pq, ao2)
    reject_assignment(@pq, ao2, 3, "")
    expect(page).to have_content("Form was not completed")
    expect(page).not_to have_content("Please select one of the reasons to reject the question")
    expect(page).to have_content("Please give us information about why you reject the question")
  end

  it "If an AO is the last to reject a question, the status should change to rejected" do
    reject_assignment(@pq, ao2, 3, "too busy!")
    create_pq_session
    expect_pq_status(@pq.uin, "Rejected")

    within_pq(@pq.uin) do
      expect(page).to have_text("#{ao1.name} rejected at:")
      expect(page).to have_text("going to the cinema")

      expect(page).to have_text("#{ao2.name} rejected at:")
      expect(page).to have_text("too busy!")
    end
  end
end
