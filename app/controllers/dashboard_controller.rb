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
    @questions = Pq.new_questions.paginate(:page => params[:page], :per_page => @@per_page).order(:date_for_answer).order(:internal_deadline).load
  end

  def in_progress
    @questions = Pq.in_progress.paginate(:page => params[:page], :per_page => @@per_page).order(:date_for_answer).order(:internal_deadline).load
  end

  def search
  end

  def by_status
    @questions = Pq.by_status(params[:qstatus]).paginate(:page => params[:page], :per_page => @@per_page).order(:date_for_answer).order(:internal_deadline).load
  end

  def in_progress_by_status
    by_status
  end

  def transferred
    @questions = Pq.transferred.paginate(:page => params[:page], :per_page => @@per_page).order(:date_for_answer).order(:internal_deadline).load
    render 'by_status'
  end

  def i_will_write
    @questions = Pq.i_will_write_flag.paginate(:page => params[:page], :per_page => @@per_page).order(:date_for_answer).order(:internal_deadline).load
    render 'in_progress_by_status'
  end


  private

  def set_state_to_in_progress
    @dashboard_state = IN_PROGRESS
  end
  def set_state_to_new
    @dashboard_state = NEW
  end
end