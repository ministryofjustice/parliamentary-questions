class StatisticsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @links = 
    [
      Link.new('On Time', '/on_time', 'Percentage of questions on answered time'),
      Link.new('Time to Assign', '/time_to_assign', 'Average time to assign a question to an Action Officer'),
      Link.new('AO Response Time', '/ao_response_time', 'Average time for an Action Officer to respond with accept/reject'),
      Link.new('AO Churn', '/ao_churn', 'Average number of times a different set of Action Officers are assigned')
    ]
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

  private

  def render_report(calculator, presenter)
    @data   = calculator.calculate
    @report = presenter.build(@data)

    respond_to do |format|
      format.html { render 'report'           }
      format.json { render json: @report.rows }
    end
  end

  Link = Struct.new(:name, :path, :description)
end