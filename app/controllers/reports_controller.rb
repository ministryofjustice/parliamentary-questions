class ReportsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  @@per_page = 10

  def ministers_by_state
    @ministers = Minister.where(deleted: false)
    @states = QuestionStateMachine.in_progress

    @counters = Pq.ministers_by_state(@ministers, @states)
  end

  def press_desk_by_state
    @states = QuestionStateMachine::STATES - [:uncommissioned]
    @pd = PressDesk.where(deleted: false)

    @counters = build_hash

    @pd.each do |pd|
      aos = get_actionofficer_ids_by_press_desk(pd.id)
      @states.each do |state|
        @counters[pd.id][state] = Pq.accepted_in(aos).in_state(state).distinct.count
      end
    end
  end

  def filter_all
    minister_id = params[:minister_id]
    press_desk_id = params[:press_desk_id]

    aos = get_actionofficer_ids_by_press_desk(press_desk_id) unless press_desk_id.blank?
    if minister_id.present? || press_desk_id.present? || state.present?
      pqs = PQ_by_all(aos,minister_id, state)
      @questions_count = pqs.count
      @questions = pqs.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
    end
    render action: 'filter_all', press_desk_id: press_desk_id, state: state, minister_id: minister_id
  end

  def PQ_by_all(aos, minister_id, state)
    @Pqs = Pq

    @Pqs = @Pqs.where('minister_id = :m_id', m_id: minister_id) if minister_id.present?
    @Pqs = @Pqs.accepted_in(aos) if !aos.present?
    @Pqs = @Pqs.in_state(state) if state.present?
    @Pqs
  end

private

  def build_hash
    Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
  end

  def get_actionofficer_ids_by_press_desk(pd_id)
    PressDesk.find(pd_id).action_officers.collect{|it| it.id}
  end
end
