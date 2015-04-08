require 'spec_helper'

describe Presenters::DashboardFilters do
  include Rails.application.routes.url_helpers

  describe "#build" do
    let(:counts) {{
      'view_all'  => 50,
      PQState::UNASSIGNED => 1,
      PQState::NO_RESPONSE => 2,
    }}

    let(:params) {{
      :controller => 'dashboard',
      :action     => 'index'
    }}

    it "produces the expected filter values" do
      expected = [
        ['View all', 50, dashboard_path, true],
        ['Unassigned', 1, dashboard_by_status_path(qstatus: PQState::UNASSIGNED), false],
        ['No response', 2, dashboard_by_status_path(qstatus: PQState::NO_RESPONSE), false],
        ['Rejected', 0, dashboard_by_status_path(qstatus: PQState::REJECTED), false],
        ['Transferred In', 0, dashboard_transferred_path, false]
      ]

      filter_values = Presenters::DashboardFilters
                        .build(counts, params)
                        .filters
                        .map { |f| [f.label, f.count, f.path, f.active?] }

      filter_values.zip(expected).each do |vals, expected_vals|
        expect(vals).to eq(expected_vals)
      end
    end
  end

  describe "#build_in_progress" do
    let(:counts) {{
      'view_all_in_progress'     => 12,
      PQState::DRAFT_PENDING     => 1,
      PQState::WITH_POD          => 2,
      PQState::POD_QUERY         => 3,
      PQState::MINISTER_CLEARED  => 4,
      'iww'                      => 2,
    }}

    let(:params) {{
      :controller => 'dashboard',
      :action     => 'in_progress_by_status',
      :qstatus    => PQState::POD_QUERY,
    }}

    it "initialises filters with the expected values" do
      expected = [
        ['View all', 12, dashboard_in_progress_path, false],
        ['Draft Pending', 1, dashboard_in_progress_by_status_path(qstatus: PQState::DRAFT_PENDING), false],
        ['With POD', 2, dashboard_in_progress_by_status_path(qstatus: PQState::WITH_POD), false],
        ['POD Query', 3, dashboard_in_progress_by_status_path(qstatus: PQState::POD_QUERY), true],
        ['POD Cleared', 0, dashboard_in_progress_by_status_path(qstatus: PQState::POD_CLEARED), false],
        ['With Minister', 0, dashboard_in_progress_by_status_path(qstatus: PQState::WITH_MINISTER), false],
        ['Ministerial Query', 0, dashboard_in_progress_by_status_path(qstatus: PQState::MINISTERIAL_QUERY), false],
        ['Minister Cleared', 4, dashboard_in_progress_by_status_path(qstatus: PQState::MINISTER_CLEARED), false],
        ['I will write', 2, dashboard_iww_path, false],
      ]

      filter_values = Presenters::DashboardFilters
                        .build_in_progress(counts, params)
                        .filters
                        .map { |f| [f.label, f.count, f.path, f.active?] }

      filter_values.zip(expected).each do |vals, expected_vals|
        expect(vals).to eq(expected_vals)
      end
    end
  end
end
