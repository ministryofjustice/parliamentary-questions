class DashboardController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  # this filters reflect the state of the 'New' or 'In Progress' tab
  before_action :set_state_to_new, only: [:index, :by_status, :transferred]
  before_action :set_state_to_in_progress, only: [:in_progress, :in_progress_by_status, :i_will_write]

  IN_PROGRESS = 'In progress'
  NEW = 'New'

  # TODO define the number of question per page
  @@per_page = 5


  def index
    LogStuff.metadata(:request_id => request.env['action_dispatch.request_id']) do
      LogStuff.tag(:dashboard) do
        LogStuff.info { "Showing dashboard" }
        @questions = paginate_collection(Pq.new_questions)
      end
    end
  end

  def in_progress
    @questions = paginate_collection(Pq.in_progress)
  end

  def search
  end

  def by_status
    @questions = paginate_collection(Pq.by_status(params[:qstatus]))
  end

  def in_progress_by_status
    by_status
  end

  def transferred
    @questions = paginate_collection(Pq.transferred)
    render 'by_status'
  end

  def i_will_write
    @questions = paginate_collection(Pq.i_will_write_flag)
    render 'in_progress_by_status'
  end


  private

  def set_state_to_in_progress
    @dashboard_state = IN_PROGRESS
  end
  def set_state_to_new
    @dashboard_state = NEW
  end

  def paginate_collection(pqs)
    pqs.paginate(:page => params[:page], :per_page => @@per_page).order("date_for_answer_has_passed asc, days_from_date_for_answer asc, progress_id desc, updated_at asc").load
  end
end
