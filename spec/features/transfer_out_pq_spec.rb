require "feature_helper"

describe "Transferring OUT questions", :js do
  before do
    DbHelpers.load_fixtures(:pqs, :ogds)
  end

  def uin
    Pq.first.uin
  end

  def transfer_out_pq(uin, date = nil)
    create_pq_session
    visit dashboard_path
    click_on uin
    sleep 2
    click_on "PQ commission"
    sleep 2
    find("select[name = 'pq[transfer_out_ogd_id]']").find(:xpath, "option[2]").select_option
    find("#transfer_out_date").set(date || Time.zone.today.strftime("%d/%m/%Y"))
    remove_focus_from_filter
    click_on "Save"
    sleep 2
  end

  it "Parli-branch should not be able to update a question with incorrect inputs" do
    transfer_out_pq(uin, "a" * 51)

    expect(page).to have_title("PQ #{uin}")
    expect(page).to have_content("Invalid date input")
    expect(page).not_to have_content("Successfully updated")
  end

  it "Parli-branch cannot transfer out a PQ without providing both a date and OGD" do
    transfer_out_pq(uin, "")

    expect(page).to have_title("PQ #{uin}")
    expect(page).to have_content("Update failed")
    expect(page).not_to have_content("Successfully updated")
  end

  it "Parli branch should be able to transfer out a PQ" do
    transfer_out_pq(uin)
    expect(page).to have_title("PQ #{uin}")
    expect(page).to have_content("Successfully updated")
  end

  it 'The transferred out PQ should have label set to "Transferred out"' do
    create_pq_session
    transfer_out_pq(uin)
    visit pq_path(uin)

    within("#pq-details-progress") do
      expect(page).to have_title("PQ #{uin}")
      expect(page).to have_content("Transferred out")
    end
  end

  it "The transferred out PQ should not be visible in the dashboard view" do
    create_pq_session
    transfer_out_pq(uin)
    visit dashboard_path

    expect(page).not_to have_content(uin)
    Pq.order(:uin).drop(1).each do |pq|
      expect(page).to have_title("Dashboard")
      expect(page).to have_content(pq.uin)
    end
  end
end
