class StatisticsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @links = Presenters::Statistics.report_links
  end

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

  def stages_time
    @data   = PqStatistics::StagesTime.calculate
    @report = Presenters::Statistics::StagesTimeReport.build(@data)

    respond_to do |format|
      format.html { render 'stages_time' }
      format.json { render json: @report }
    end
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
