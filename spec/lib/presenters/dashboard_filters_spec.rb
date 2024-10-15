require "spec_helper"

describe Presenters::DashboardFilters do
  include Rails.application.routes.url_helpers

  describe "#build" do
    let(:counts) do
      {
        "view_all" => 50,
        PqState::UNASSIGNED => 1,
        PqState::NO_RESPONSE => 2,
      }
    end

    let(:params) do
      {
        controller: "dashboard",
        action: "index",
      }
    end

    it "produces the expected filter values" do
      expected = [
        ["View all", 50, dashboard_path, true],
        ["Unassigned", 1, dashboard_by_status_path(qstatus: PqState::UNASSIGNED), false],
        ["No response", 2, dashboard_by_status_path(qstatus: PqState::NO_RESPONSE), false],
        ["Rejected", 0, dashboard_by_status_path(qstatus: PqState::REJECTED), false],
        ["Transferred In", 0, dashboard_transferred_path, false],
      ]

      filter_values =
        described_class
        .build(counts, params)
        .filters
        .map { |f| [f.label, f.count, f.path, f.active?] }

      filter_values.zip(expected).each do |vals, expected_vals|
        expect(vals).to eq(expected_vals)
      end
    end
  end

  describe "#build_in_progress" do
    let(:counts) do
      {
        "view_all_in_progress" => 12,
        PqState::DRAFT_PENDING => 1,
        PqState::WITH_POD => 2,
        PqState::MINISTER_CLEARED => 4,
      }
    end

    let(:params) do
      {
        controller: "dashboard",
        action: "in_progress_by_status",
        qstatus: PqState::WITH_POD,
      }
    end

    it "initialises filters with the expected values" do
      expected = [
        ["View all", 12, dashboard_in_progress_path, false],
        ["Draft Pending", 1, dashboard_in_progress_by_status_path(qstatus: PqState::DRAFT_PENDING), false],
        ["With POD", 2, dashboard_in_progress_by_status_path(qstatus: PqState::WITH_POD), true],
        ["POD Cleared", 0, dashboard_in_progress_by_status_path(qstatus: PqState::POD_CLEARED), false],
        ["With Minister", 0, dashboard_in_progress_by_status_path(qstatus: PqState::WITH_MINISTER), false],
        ["Ministerial Query", 0, dashboard_in_progress_by_status_path(qstatus: PqState::MINISTERIAL_QUERY), false],
        ["Minister Cleared", 4, dashboard_in_progress_by_status_path(qstatus: PqState::MINISTER_CLEARED), false],
      ]

      filter_values =
        described_class
        .build_in_progress(counts, params)
        .filters
        .map { |f| [f.label, f.count, f.path, f.active?] }

      filter_values.zip(expected).each do |vals, expected_vals|
        expect(vals).to eq(expected_vals)
      end
    end
  end
end
