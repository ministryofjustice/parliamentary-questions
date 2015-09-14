class DashboardController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  IN_PROGRESS = 'In progress'
  NEW         = 'New'
  BACKLOG     = 'Backlog'
  PER_PAGE    = 15

  def index
    @dashboard_state = NEW
    update_page_title "Dashboard"
    load_pq_with_counts(@dashboard_state) { Pq.new_questions.sorted_for_dashboard }
  end

  def by_status
    @dashboard_state = NEW
    load_pq_with_counts(@dashboard_state) { Pq.by_status(params[:qstatus]).sorted_for_dashboard }
    update_page_title "#{params[:qstatus]}"
    render 'index'
  end


  def in_progress_by_status
    @dashboard_state = IN_PROGRESS
    load_pq_with_counts(@dashboard_state) { Pq.by_status(params[:qstatus]).sorted_for_dashboard }
    update_page_title "#{params[:qstatus]}"
    render 'index'
  end


  def backlog
    @dashboard_state = BACKLOG
    load_pq_with_counts(@dashboard_state) {  Pq.backlog.sorted_for_dashboard }
    update_page_title "#{params[:qstatus]}"
    render 'index'
  end

=begin
  def transferred
    load_pq_with_counts(NEW) { Pq.transferred.sorted_for_dashboard }
    render 'index'
  end
=end

=begin
  def i_will_write
    load_pq_with_counts(IN_PROGRESS) { Pq.i_will_write_flag.sorted_for_dashboard }
    render 'index'
  end
=end

  def in_progress
    @dashboard_state = IN_PROGRESS
    update_page_title "In progress"
    load_pq_with_counts(IN_PROGRESS) { Pq.in_progress.sorted_for_dashboard }
    render 'index'
  end

  def search
  end

  private

  def load_pq_with_counts(dashboard_state)
    pq_counts        = Pq.counts_by_state
    @action_officers = ActionOfficer.active
    @dashboard_state = dashboard_state
    #@questions       = paginate_collection(yield) if block_given?
    @questions       = (yield) if block_given?
    @statuses = @questions.all.map {|q| q.state}.uniq
    @question_types = @questions.where("question_type != 'Follow-up IWW'").map {|q| q.question_type}.uniq
    @transfers = @questions.all.map {|q| q.transferred}.uniq
    @i_will_writes = @questions.all.map {|q| q.i_will_write}.uniq
    @answering_minister_names = @questions.where('minister_id > 0').map {|q| q.minister.name}.uniq
    @policy_minister_names = @questions.where('policy_minister_id > 0').map {|q| q.policy_minister.name}.uniq
    @filters         =
      if dashboard_state == IN_PROGRESS
        Presenters::DashboardFilters.build_in_progress(pq_counts, params)
      elsif dashboard_state == BACKLOG
        Presenters::DashboardFilters.backlog(pq_counts, params)
      else
        Presenters::DashboardFilters.build(pq_counts, params)
      end
  end

  def paginate_collection(pqs)
    page = params.fetch(:page, 1)
    pqs.paginate(page: page, per_page: PER_PAGE)
  end
end
