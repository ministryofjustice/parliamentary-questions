class ProgressReportController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  @@per_page = 10




  def index
    minister_id = params[:minister_id]
    progress_id = params[:progress_id]

    progress_counters = PQ.where('minister_id = ?', minister_id).group('progress_id').count

    @progresses = []

    Progress.order('id').each do |it|
      count = progress_counters[it.id] || 0
      @progresses.push({id: it.id, name: it.name, count: count})
    end

    @questions = PQ.where('progress_id = ? AND minister_id = ?', progress_id, minister_id).paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load

    render action: 'index', minister_id: minister_id, progress_id: progress_id
  end


end