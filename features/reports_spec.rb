require "feature_helper"

describe "Minister Report", js: true do
  include Features::PqHelpers

  def within_report_state(state, &block)
    css = "tr[data='report-state-#{state}']"
    within(css, &block)
  end

  def expect_report_to_have(record, state, count)
    param_name =
      case record
      when Minister  then "minister_id"
      when PressDesk then "press_desk_id"
      else
        raise ArgumentError, "record must be either minister or press desk"
      end
    el = find("a[href=\"/reports/filter_all?#{param_name}=#{record.id}&state=#{state}\"]")
    expect(el.text).to eq(count.to_s)
  end

  before do
    DBHelpers.load_feature_fixtures
    create_pq_session
  end

  let(:action_officer)  { ActionOfficer.first                        }
  let(:minister)        { Minister.find_by(name: "Chris Grayling")   }
  let(:pq1)             { PQA::QuestionLoader.new.load_and_import(5) }
  let(:pq2)             { PQA::QuestionLoader.new.load_and_import(5) }

  it "Parli-branch accesses the minister report and follows a link to the filter results page" do
    uins = [pq1, pq2].map(&:uin)

    uins.each do |uin|
      commission_question(uin, [action_officer], minister)
      accept_assignment(Pq.find_by(uin:), action_officer)
    end

    visit reports_ministers_by_progress_path

    expect_report_to_have(minister, PqState::DRAFT_PENDING, 2)
    within_report_state(PqState::DRAFT_PENDING) do
      click_on("2")
    end

    uins.each do |uin|
      expect(page).to have_content(uin)
    end
  end

  it "Parli-branch accesses the press desk report and follows a link to the filter results page" do
    commission_question(pq1.uin, [action_officer], minister)
    accept_assignment(pq1, action_officer)

    visit reports_press_desk_by_progress_path

    expect_report_to_have(action_officer.press_desk, PqState::DRAFT_PENDING, 1)
    within_report_state(PqState::DRAFT_PENDING) do
      click_on("1")
    end
    expect(page).to have_content(pq1.uin)
  end
end
