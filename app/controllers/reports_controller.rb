class ReportsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  PER_PAGE = 15

  def ministers_by_progress
    update_page_title('Minister report')
    report_data = Pq.count_in_progress_by_minister
    @report     = Presenters::Report.ministers(report_data, Minister.active)
    render 'report'
  end

  def press_desk_by_progress
    update_page_title('Press Desk report')
    report_data = Pq.count_accepted_by_press_desk
    @report     = Presenters::Report.press_desk(report_data, PressDesk.active)
    render 'report'
  end

  def filter_all
    state            = params[:state]
    minister_id      = params[:minister_id]
    press_desk_id    = params[:press_desk_id]

    @ministers       = Minister.active
    @action_officers = ActionOfficer.active
    @press_desks     = PressDesk.active
    @questions       = Pq.filter_for_report(state, minister_id, press_desk_id)
                         .paginate(page: params[:page], per_page: PER_PAGE)
    @states          = PQState::ALL.map { |s| [PQState.state_label(s), s] }

    render 'filter_all'
  end
end
