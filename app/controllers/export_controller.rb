class ExportController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def csv
    with_valid_dates('index') do |date_from, date_to|
      export = Export::PqDefault.new(date_from, date_from)
      send_data(export.to_csv, content_type: 'text/csv')
    end
  end

  def csv_for_pod
    with_valid_dates('index_for_pod') do |date_from, date_to|
      export = Export::PqPod.new(date_from, date_from)
      send_data(export.to_csv, content_type: 'text/csv')
    end
  end

  private

  def with_valid_dates(form_template)
    begin
      date_from, date_to = [
        DateTime.parse(params[:date_from]),
        DateTime.parse(params[:date_to])
      ]
      yield(date_from, date_to)
    rescue ArgumentError
      flash[:error] = "Invalid date input!"
      render(form_template, status: 400)
    end
  end
end
