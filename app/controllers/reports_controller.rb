class ReportsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  @@per_page = 10

  def ministers_by_progress
    @p = Progress.all
    @m = Minister.all
    @pq = PQ.in_progress
  end

  def ministers_filter
    minister_id = params[:minister_id]
    progress_id = params[:progress_id]
    @progresses = []

    if minister_id.nil? || minister_id.empty?
      return render action: 'ministers_filter', minister_id: minister_id, progress_id: progress_id
    end

    progress_counters = PQ.visibles.where('minister_id = ?', minister_id).group('progress_id').count

    Progress.where(name: Progress.visible).each do |it|
      count = progress_counters[it.id] || 0
      @progresses.push({id: it.id, name: it.name, count: count})
    end

    if !progress_id.nil? && !progress_id.empty?
      pqs = PQ.visibles.where('progress_id = ? AND minister_id = ?', progress_id, minister_id)
    else
      pqs = PQ.visibles.where('minister_id = ?', minister_id)
    end

    @questions_count = pqs.count
    @questions = pqs.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load

    render action: 'ministers_filter', minister_id: minister_id, progress_id: progress_id
  end
end
