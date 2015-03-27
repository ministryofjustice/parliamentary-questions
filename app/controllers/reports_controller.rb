class ReportsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  PER_PAGE = 15

  def ministers_by_progress
    update_page_title('Minister report')
    report_data = Pq.in_progress_pqs_by_minister
    @report     = Report.ministers(report_data, Minister.active)
    render 'report'
  end

  def press_desk_by_progress
    update_page_title('Press Desk report')
    report_data = Pq.accepted_by_press_desk
    @report     = Report.press_desk(report_data, PressDesk.active)
    render 'report'
  end
end
