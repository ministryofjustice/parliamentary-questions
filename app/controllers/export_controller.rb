class ExportController < ApplicationController
  include Validators::DateInput

  before_action :authenticate_user!

  def index
    update_page_title("Export PQs")
  end

  def csv
    run_export(Export::PqDefault, "index.html.slim")
  end

  def csv_quick
    run_export(Export::PqSelection, "index.html.slim")
  end

private

  def run_export(export_type, template)
    with_valid_dates(template) do |date_from, date_to|
      export = export_type.new(date_from, date_to, params[:pqs_comma_separated])
      send_data(export.to_csv, content_type: "text/csv")
    end
  end

  def with_valid_dates(form_template)
    date_from = parse_datetime(params[:date_from])
    date_to = parse_datetime(params[:date_to])
    yield(date_from, date_to)
  rescue DateTimeInputError
    flash[:error] = "Invalid date input!"
    update_page_title("Export PQs to CSV")
    render form_template, status: :unprocessable_entity
  end
end
