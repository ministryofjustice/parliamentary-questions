require 'feature_helper'

feature 'Minister Report', js: true do
  include Features::PqHelpers

  def within_report_state(state, &)
    css = "tr[data='report-state-#{state}']"
    within(css, &)
  end

  def expect_report_to_have(record, state, count)
    param_name =
      case record
      when Minister  then 'minister_id'
      when PressDesk then 'press_desk_id'
      else
        raise ArgumentError, 'record must be either minister or press desk'
      end
    el = find("a[href=\"/reports/filter_all?#{param_name}=#{record.id}&state=#{state}\"]")
    expect(el.text).to eq(count.to_s)
  end

  before(:each) do
    DBHelpers.load_feature_fixtures
    @pq1, @pq2, = PQA::QuestionLoader.new.load_and_import(10)
    create_pq_session
  end

  let(:action_officer) { ActionOfficer.first }
  let(:minister)       { Minister.find_by(name: 'Chris Grayling') }

  scenario 'Parli-branch accesses the minister report and follows a link to the filter results page' do
    uins = [@pq1, @pq2].map(&:uin)

    uins.each do |uin|
      commission_question(uin, [action_officer], minister)
      accept_assignment(Pq.find_by(uin:), action_officer)
    end

    visit reports_ministers_by_progress_path

    expect_report_to_have(minister, PQState::DRAFT_PENDING, 2)
    within_report_state(PQState::DRAFT_PENDING) do
      click_on('2')
    end

    uins.each do |uin|
      expect(page).to have_content(uin)
    end
  end

  scenario 'Parli-branch accesses the press desk report and follows a link to the filter results page' do
    commission_question(@pq1.uin, [action_officer], minister)
    accept_assignment(@pq1, action_officer)

    visit reports_press_desk_by_progress_path

    expect_report_to_have(action_officer.press_desk, PQState::DRAFT_PENDING, 1)
    within_report_state(PQState::DRAFT_PENDING) do
      click_on('1')
    end
    expect(page).to have_content(@pq1.uin)
  end
end
