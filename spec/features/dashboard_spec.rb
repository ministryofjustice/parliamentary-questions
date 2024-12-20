require "feature_helper"

describe "Dashboard view", :js do
  let!(:pqs) { PQA::QuestionLoader.new.load_and_import(3) }

  def search_for(uin)
    create_pq_session
    visit dashboard_path
    fill_in "Search by UIN", with: uin
    find("#search_button").click
  end

  it "Parli-branch can view the questions tabled for today" do
    create_pq_session
    visit dashboard_path

    pqs.each do |pq|
      within_pq(pq.uin) do
        expect(page).to have_title("Dashboard")
        expect(page).to have_content(pq.text)
        # expect(page).to have_content(pq.action_officers)
      end
    end
  end

  it "Parli-branch can find a question by uin" do
    uin = pqs.first.uin
    search_for(uin)

    expect(page).to have_title("PQ #{uin}")
    expect(page).to have_content(uin)
    expect(page).to have_current_path pq_path(uin), ignore_query: true
  end

  it "Parli-branch sees an error message if no question matches the uin" do
    search_for("gibberish")

    expect(page).to have_title("Dashboard")
    expect(page).to have_current_path dashboard_path, ignore_query: true
    expect(page).to have_content "Question with UIN 'gibberish' not found"
  end
end
