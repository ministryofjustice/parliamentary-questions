require "feature_helper"

describe "Managing action officers", js: true, suspend_cleaner: true do
  before do
    DbHelpers.load_feature_fixtures
  end

  after do
    DatabaseCleaner.clean
  end

  def dd
    DeputyDirector.first.name
  end

  def press_desk
    PressDesk.first.name
  end

  def create_ao(name, email)
    create_pq_session
    visit new_action_officer_path

    fill_in "Name", with: name
    fill_in "Email", with: email
    select dd, from: "Deputy Director"
    select press_desk, from: "Press Desk"
    click_on "Save"
  end

  let(:ao_email) { "action_officer@pq.com" }
  let(:ao_name)  { "action officer 1" }

  it "Parli-branch can create a new action officer" do
    create_ao(ao_name, ao_email)

    expect(page.title).to include("Action officers")
    expect(page).to have_content "Action officer was successfully created"
    within("#admin-ao-list") { expect(page).to have_content ao_name }
  end

  it "Parli-branch can edit an existing action officer" do
    create_pq_session
    visit action_officers_path
    click_on ao_name
    click_on "Edit"

    expect(page).to have_title "Edit action officer"
    fill_in "Name", with: "another action officer"
    click_on "Save"

    expect(page).to have_title "Action officer details"
    expect(page).to have_content "Action officer was successfully updated"
    expect(page).to have_content "another action officer"
  end

  it "Parli-branch cannot duplicate AO email for the same deputy director" do
    create_ao(ao_name, ao_email)
    create_ao(ao_name, ao_email)

    expect(page).to have_title "Add action officer"
    expect(page).to have_content "an action officer cannot be assigned twice to the same deputy director"
    expect(page).not_to have_content "Action officer was successfully created"
  end

  it "Parli-branch can see inactive action officers" do
    create_pq_session
    visit action_officers_path
    ao = ActionOfficer.last
    expect(page).to have_content ao.name

    ao.update!(deleted: true)
    ao.update!(updated_at: 2.weeks.ago)

    visit action_officers_path
    expect(page).not_to have_content ao.name

    click_link "View inactive action officers"
    expect(page).to have_content ao.name
    expect(page).not_to have_content "View inactive action officers"

    click_link "View active action officers"
    expect(page).not_to have_content ao.name
    expect(page).not_to have_content "View active action officers"
  end
end
