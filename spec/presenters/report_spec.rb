require 'spec_helper'

describe Report do
  include Rails.application.routes.url_helpers

  def header_values(r)
    r.header_cells.map { |c| [c.label, c.path] }
  end

  def row_values(r)
    [r.label, r.cells.map { |c| [c.count, c.path] }]
  end

  let(:ministers)       { DBHelpers.ministers }
  let(:press_desks)     { DBHelpers.press_desks }
  let(:minister_report) { Report.ministers(report_data, ministers) }
  let(:pd_report)       { Report.press_desk(report_data, press_desks) }
  let(:report_data)     {{}}

  describe "#header_values" do
    context "minister report" do
      it "produces the expected header values" do
        expected = ministers.map { |m| [m.name, filter_all_path(minister_id: m.id)] }
        expect(header_values(minister_report)).to eq(expected)
      end
    end

    context "press desk report" do
      it "produces the expected header values" do
        expected = press_desks.map { |pd| [pd.name, filter_all_path(press_desk_id: pd.id)] }
        expect(header_values(pd_report)).to eq(expected)
      end
    end
  end

  describe "#rows" do
    context "when no data is supplied" do
      it "produces the expected row values" do
        actual   = minister_report.rows.map { |r| row_values(r) }
        expected = PQState::IN_PROGRESS.map do |state|
          [PQState.state_label(state), ministers.map { |m| [0, filter_all_path(minister_id: m.id, state: state)] }]
        end

        expected.zip(actual).each do |expected_row, row|
          expect(row).to eq(expected_row)
        end
      end
    end

    context "when some data is supplied" do
      let(:report_data) {{
        PQState::WITH_POD => {
          press_desks[0].id => 10,
          press_desks[1].id => 20
        }
      }}

      it "produces the expected row values" do
        state    = PQState::WITH_POD
        label    = PQState.state_label(state)
        actual   = pd_report.rows.map { |r| row_values(r) }.find {|s, _| s == label }
        expected = [
          label, [
            [10, filter_all_path(press_desk_id: press_desks[0].id, state: state)],
            [20, filter_all_path(press_desk_id: press_desks[1].id, state: state)],
          ]
        ]
        expect(actual).to eq(expected)
      end
    end
  end
end
