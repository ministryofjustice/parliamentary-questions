class StatisticsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def on_time
    render_report(
      PqStatistics::PercentOnTime, 
      Presenters::Statistics::OnTimeReport
    )
  end

  def time_to_assign
    render_report(
      PqStatistics::TimeToAssign, 
      Presenters::Statistics::TimeToAssignReport
    )
  end

  def ao_response_time
    render_report(
      PqStatistics::AoResponseTime, 
      Presenters::Statistics::AoResponseTimeReport
    )
  end

  def ao_churn
    render_report(
      PqStatistics::AoChurn, 
      Presenters::Statistics::AoChurnReport
    )
  end

  private

  def render_report(calculator, presenter)
    @data   = calculator.calculate
    @report = presenter.build(@data)

    respond_to do |format|
      format.html { render 'report'           }
      format.json { render json: @report.rows }
    end
  end
end