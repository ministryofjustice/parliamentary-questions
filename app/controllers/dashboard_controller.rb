class DashboardController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  IN_PROGRESS = 'In progress'
  NEW         = 'New'
  PER_PAGE    = 15

  def index
    load_pq_with_counts(NEW) { Pq.new_questions }
  end

  def by_status
    load_pq_with_counts(NEW) { Pq.by_status(params[:qstatus]) }
    render 'index'
  end

  def in_progress_by_status
    by_status
  end

  def transferred
    load_pq_with_counts(NEW) { Pq.transferred }
    render 'index'
  end

  def i_will_write
    load_pq_with_counts(IN_PROGRESS) { Pq.i_will_write_flag }
    render 'index'
  end

  def in_progress
    load_pq_with_counts(IN_PROGRESS) { Pq.in_progress }
    render 'index'
  end

  def search
  end

  private

  def load_pq_with_counts(dashboard_state)
    pq_counts        = Pq.counts_by_state
    @dashboard_state = dashboard_state
    @questions       = paginate_collection(yield) if block_given?
    @filters         =
      if dashboard_state == IN_PROGRESS
        DashboardFilters.build_in_progress(pq_counts, params)
      else
        DashboardFilters.build(pq_counts, params)
      end
  end

  def paginate_collection(pqs)
    page = params.fetch(:page, 1)
    pqs.paginate(page: page, per_page: PER_PAGE)
      .order("date_for_answer_has_passed asc, days_from_date_for_answer asc, progress_id desc, updated_at asc")
      .load
  end
end
