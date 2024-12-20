class DashboardController < ApplicationController
  before_action :authenticate_user!

  BACKLOG     = "Backlog".freeze
  IN_PROGRESS = "In progress".freeze
  NEW         = "New".freeze
  UNASSIGNED  = "unassigned".freeze

  def backlog
    @dashboard_state = BACKLOG
    load_pq_with_counts(@dashboard_state) { Pq.backlog.sorted_for_dashboard }
    update_page_title "Backlog"
    render "index"
  end

  def by_status
    @dashboard_state = NEW
    load_pq_with_counts(@dashboard_state) { Pq.by_status(params[:qstatus]).sorted_for_dashboard }
    update_page_title params[:qstatus].to_s
    render "index"
  end

  def in_progress
    @dashboard_state = IN_PROGRESS
    update_page_title "In progress"
    load_pq_with_counts(IN_PROGRESS) { Pq.in_progress.sorted_for_dashboard }
    render "index"
  end

  def in_progress_by_status
    @dashboard_state = IN_PROGRESS
    load_pq_with_counts(@dashboard_state) { Pq.by_status(params[:qstatus]).sorted_for_dashboard }
    update_page_title params[:qstatus].to_s
    render "index"
  end

  def index
    @dashboard_state = NEW
    update_page_title "Dashboard"
    load_pq_with_counts(@dashboard_state) { Pq.new_questions.sorted_for_dashboard }
  end

  def unassigned
    @dashboard_state = UNASSIGNED
    load_pq_with_counts(@dashboard_state) { Pq.unassigned.sorted_for_dashboard }
    render "index"
  end

private

  def load_pq_with_counts(dashboard_state)
    pq_counts                 = Pq.counts_by_state
    @action_officers          = ActionOfficer.active
    @dashboard_state          = dashboard_state
    @questions                = yield if block_given?
    @statuses                 = @questions.all.map(&:state).uniq
    @question_types           = @questions.where("question_type != 'Follow-up IWW'").map(&:question_type).uniq
    @transfers                = @questions.all.map(&:transferred).uniq
    @answering_minister_names = @questions.where("minister_id > 0").map { |q| q.minister.name }.uniq
    @policy_minister_names    = @questions.where("policy_minister_id > 0").map { |q| q.policy_minister.name }.uniq
    @filters =
      case dashboard_state
      when IN_PROGRESS
        Presenters::DashboardFilters.build_in_progress(pq_counts, params)
      when BACKLOG
        Presenters::DashboardFilters.backlog(pq_counts, params)
      else
        Presenters::DashboardFilters.build(pq_counts, params)
      end
  end
end
