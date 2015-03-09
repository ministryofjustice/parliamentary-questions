class ExportController < ApplicationController
  include Validators::DateInput

  before_action :authenticate_user!, PQUserFilter

  def csv
    run_export(Export::PqDefault, 'index')
  end

  def csv_for_pod
    run_export(Export::PqPod, 'index_for_pod')
  end

  private

  def run_export(export_type, template)
    with_valid_dates(template) do |date_from, date_to|
      export = export_type.new(date_from, date_to)
      send_data(export.to_csv, content_type: 'text/csv')
    end
  end

  def with_valid_dates(form_template)
    date_from, date_to = [
      parse_datetime(params[:date_from]),
      parse_datetime(params[:date_to])
    ]
    yield(date_from, date_to)
    rescue DateTimeInputError
      flash[:error] = 'Invalid date input!'
      render(form_template, status: 422)
  end
end
