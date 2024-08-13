require "feature_helper"

describe "Rejecting questions", :js do
  let(:ao_first) { ActionOfficer.find_by(email: "ao_first@pq.com") }
  let(:ao_second) { ActionOfficer.find_by(email: "ao_second@pq.com") }
  let(:minister) { Minister.first }
  let(:pq) { FactoryBot.create(:pq) }

  before do
    DbHelpers.load_fixtures(:action_officers, :ministers)
  end

  it "Parli-branch member allocates a question to selected AOs" do
    commission_question(pq.uin, [ao_first, ao_second], minister)
  end

  it "Following the email link should let an AO reject the question" do
    commission_question(pq.uin, [ao_first, ao_second], minister)
    reject_assignment(pq, ao_first, 2, "going to the cinema")
    expect(page).to have_title("PQ rejected")
    expect(page).to have_content(/thank you for your response/i)
  end

  it "Parli-branch should see which AOs have rejected the question" do
    commission_question(pq.uin, [ao_first, ao_second], minister)
    reject_assignment(pq, ao_first, 2, "going to the cinema")
    create_pq_session
    visit dashboard_path

    within_pq(pq.uin) do
      expect(page).to have_title("Dashboard")
      expect(page).to have_text("#{ao_first.name} rejected at:")
      expect(page).to have_text("going to the cinema")
    end
  end

  it "The question status should remain no response" do
    commission_question(pq.uin, [ao_first, ao_second], minister)
    reject_assignment(pq, ao_first, 2, "going to the cinema")
    create_pq_session
    expect_pq_status(pq.uin, "No response")
  end

  it "If an AO submits an empty acceptance form, show an error" do
    commission_question(pq.uin, [ao_first, ao_second], minister)
    visit_assignment_url(pq, ao_second)
    click_on "Save Response"
    expect(page).to have_content("Form was not completed")
    expect(page).not_to have_content("Please select one of the reasons to reject the question")
  end

  it "If an AO rejects without a reason, show an error" do
    create_pq_session
    commission_question(pq.uin, [ao_first, ao_second], minister)
    visit_assignment_url(pq, ao_second)
    choose "Reject"
    click_on "Save Response"
    expect(page).to have_content("Form was not completed")
    expect(page).to have_content("Please select one of the reasons to reject the question")
    expect(page).to have_content("Please give us information about why you reject the question")
  end

  it "If an AO rejects without selecting from the dropdown, show an error" do
    commission_question(pq.uin, [ao_first, ao_second], minister)
    visit_assignment_url(pq, ao_second)
    choose "Reject"
    fill_in "allocation_response_reason", with: "no time"
    click_on "Save Response"
    expect(page).to have_content("Form was not completed")
    expect(page).to have_content("Please select one of the reasons to reject the question")
    expect(page).not_to have_content("Please give us information about why you reject the question")
  end

  it "If an AO rejects without typing a reason, show an error" do
    commission_question(pq.uin, [ao_first, ao_second], minister)
    visit_assignment_url(pq, ao_second)
    reject_assignment(pq, ao_second, 3, "")
    expect(page).to have_content("Form was not completed")
    expect(page).not_to have_content("Please select one of the reasons to reject the question")
    expect(page).to have_content("Please give us information about why you reject the question")
  end

  it "If an AO is the last to reject a question, the status should change to rejected" do
    commission_question(pq.uin, [ao_first, ao_second], minister)
    reject_assignment(pq, ao_first, 3, "going to the cinema")
    reject_assignment(pq, ao_second, 3, "too busy!")
    create_pq_session
    expect_pq_status(pq.uin, "Rejected")

    within_pq(pq.uin) do
      expect(page).to have_text("#{ao_first.name} rejected at:")
      expect(page).to have_text("going to the cinema")

      expect(page).to have_text("#{ao_second.name} rejected at:")
      expect(page).to have_text("too busy!")
    end
  end
end
