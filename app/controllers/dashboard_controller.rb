class DashboardController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  IN_PROGRESS = 'In progress'
  NEW         = 'New'
  PER_PAGE    = 50

  def index
    @dashboard_state = NEW
    LogStuff.metadata(:request_id => request.env['action_dispatch.request_id']) do
      LogStuff.tag(:dashboard) do
        LogStuff.info { "Showing dashboard" }
        @questions = paginate_collection(Pq.new_questions)
      end
    end
  end

  def by_status
    @dashboard_state = NEW
    @questions = paginate_collection(Pq.by_status(params[:qstatus]))
  end

  def transferred
    @dashboard_state = NEW
    @questions = paginate_collection(Pq.transferred)
    render 'by_status'
  end

  def in_progress_by_status
    @dashboard_state = IN_PROGRESS
    by_status
  end

  def i_will_write
    @dashboard_state = IN_PROGRESS
    @questions = paginate_collection(Pq.i_will_write_flag)
    render 'in_progress_by_status'
  end

  def in_progress
    @dashboard_state = IN_PROGRESS
    @questions = paginate_collection(Pq.in_progress)
  end

  def search
  end

  private

  def paginate_collection(pqs)
    page = params.fetch(:page, 1)
    pqs.paginate(page: page, per_page: PER_PAGE)
      .order("date_for_answer_has_passed asc, days_from_date_for_answer asc, progress_id desc, updated_at asc")
      .load
  end
end
