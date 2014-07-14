class DashboardController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  # TODO define the number of question per page
  @@per_page = 5

  def index
    @questions = PQ.new_questions.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load

    # FIXME this is just testing that statsd works
    # counter of times that the dashboard is hit
    $statsd.increment 'dashboard.hits'

  end

  def in_progress
    @questions = PQ.in_progress.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
  end

  def search
  end

  def by_status
    @questions = PQ.by_status(params[:qstatus]).paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
  end

  def in_progress_by_status
    by_status
  end

  def transferred
    @questions = PQ.transferred.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
    render 'by_status'
  end

  def i_will_write
    @questions = PQ.i_will_write_flag.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
    render 'in_progress_by_status'
  end
end