require 'spec_helper'

describe DashboardFilters do
  include Rails.application.routes.url_helpers

  describe "#build" do
    let(:counts) {{
      'view_all'  => 50,
      Progress.UNASSIGNED => 1,
      Progress.NO_RESPONSE => 2,
    }}

    let(:params) {{
      :controller => 'dashboard',
      :action     => 'index'
    }}

    it "produces the expected filter values" do
      expected = [
        ['View all', 50, dashboard_path, true],
        ['Unassigned', 1, dashboard_by_status_path(qstatus: Progress.UNASSIGNED), false],
        ['No response', 2, dashboard_by_status_path(qstatus: Progress.NO_RESPONSE), false],
        ['Rejected', 0, dashboard_by_status_path(qstatus: Progress.REJECTED), false],
        ['Transferred In', 0, dashboard_transferred_path, false]
      ]

      expect(DashboardFilters
        .build(counts, params)
        .filters
        .map { |f| [f.label, f.count, f.path, f.active?]

      }).to eq(expected)
    end
  end

  describe "#build_in_progress" do
    let(:counts) {{
      'view_all_in_progress'     => 12,
      Progress.DRAFT_PENDING     => 1,
      Progress.WITH_POD          => 2,
      Progress.POD_QUERY         => 3,
      Progress.MINISTER_CLEARED  => 4,
      'iww'                      => 2,
    }}

    let(:params) {{
      :controller => 'dashboard',
      :action     => 'in_progress_by_status',
      :qstatus    => Progress.POD_QUERY,
    }}

    it "initialises filters with the expected values" do
      expected = [
        ['View all', 12, dashboard_in_progress_path, false],
        ['Draft Pending', 1, dashboard_in_progress_by_status_path(qstatus: Progress.DRAFT_PENDING), false],
        ['With POD', 2, dashboard_in_progress_by_status_path(qstatus: Progress.WITH_POD), false],
        ['POD Query', 3, dashboard_in_progress_by_status_path(qstatus: Progress.POD_QUERY), true],
        ['POD Cleared', 0, dashboard_in_progress_by_status_path(qstatus: Progress.POD_CLEARED), false],
        ['With Minister', 0, dashboard_in_progress_by_status_path(qstatus: Progress.WITH_MINISTER), false],
        ['Ministerial Query', 0, dashboard_in_progress_by_status_path(qstatus: Progress.MINISTERIAL_QUERY), false],
        ['Minister Cleared', 4, dashboard_in_progress_by_status_path(qstatus: Progress.MINISTER_CLEARED), false],
        ['I will write', 2, dashboard_iww_path, false],
      ]

      expect(DashboardFilters
        .build_in_progress(counts, params)
        .filters
        .map { |f| [f.label, f.count, f.path, f.active?]
      }).to eq(expected)
    end
  end
end
