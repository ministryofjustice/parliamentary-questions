require "feature_helper"

describe "Parli-branch manually rejecting and re-assigning OAs", :js do
  let(:ao_first) { ActionOfficer.first }
  let(:ao_second) { ActionOfficer.second }
  let(:minister) { Minister.first }
  let(:policy_minister) { Minister.limit(2)[1] }
  let!(:pq) { FactoryBot.create(:pq) }

  before do
    DbHelpers.load_fixtures(:action_officers, :ministers)
  end

  def selected_option_text(field_name)
    find("select[name='#{field_name}'] option[selected='selected']").text
  end

  it "PB commissions a question to two AOs" do
    commission_question(pq.uin, [ao_first, ao_second], minister, policy_minister)
  end

  it "PB manually rejects the first AO" do
    commission_question(pq.uin, [ao_first, ao_second], minister, policy_minister)
    create_pq_session
    visit pq_path(pq.uin)
    click_on "Commission"

    click_on "Manually reject #{ao_first.name}"
    expect(page).to have_title("PQ #{pq.uin}")
    expect(page).to have_content("#{pq.uin} manually rejected")

    visit pq_path(pq.uin)
    click_on "Commission"
    expect(page).to have_title("PQ #{pq.uin}")
    expect(page).to have_content("rejected manually by pq@pq.com")
    expect_pq_status(pq.uin, "No response")
  end

  it "PB manually rejects the last AO" do
    commission_question(pq.uin, [ao_first], minister, policy_minister)
    create_pq_session
    visit pq_path(pq.uin)
    click_on "Commission"
    click_on "Manually reject #{ao_first.name}"
    expect_pq_status(pq.uin, "Rejected")

    within_pq(pq.uin) do
      selected_minister = selected_option_text("commission_form[minister_id]")
      selected_policy_minister = selected_option_text("commission_form[policy_minister_id]")
      expect(selected_minister).to eq(minister.name)
      expect(selected_policy_minister).to eq(policy_minister.name)
    end
  end
end
