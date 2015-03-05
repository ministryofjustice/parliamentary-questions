class ReportsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  PER_PAGE = 10

  def ministers_by_progress
    @ministers = Minister.active
    @progresses = Progress.where(name: Progress.in_progress_questions)

    @counters = Pq.ministers_by_progress(@ministers, @progresses)
  end

  def press_desk_by_progress
    @p = Progress.where("name != 'Unassigned'")
    @pd = PressDesk.active

    @counters = build_hash

    @pd.each do |pd|
      aos = get_actionofficer_ids_by_press_desk(pd.id)
      @p.each do |p|
        @counters[pd.id][p.id] = Pq.accepted_in(aos).where('progress_id = ?', p.id).distinct.count
      end
    end
  end

  def filter_all
    minister_id = params[:minister_id]
    press_desk_id = params[:press_desk_id]
    progress_id = params[:progress_id]

    aos = get_actionofficer_ids_by_press_desk(press_desk_id) unless press_desk_id.blank?
    if !minister_id.blank? || !press_desk_id.blank? || !progress_id.blank?
      pqs = PQ_by_all(aos,minister_id,progress_id)
      @questions_count = pqs.count
      @questions = pqs.paginate(:page => params[:page], :per_page => PER_PAGE).order(:internal_deadline).load
    end
    render action: 'filter_all', press_desk_id: press_desk_id, progress_id: progress_id, minister_id: minister_id
  end


  private

  def PQ_by_all(aos, minister_id, progress_id)
    @Pqs = Pq

    if !minister_id.blank?
      @Pqs = @Pqs.where('minister_id = :m_id', m_id: minister_id)
    end
    if !aos.nil?
      @Pqs = @Pqs.accepted_in(aos)
    end
    if !progress_id.blank?
      @Pqs = @Pqs.where('progress_id = :p_id', p_id:progress_id)
    end
    @Pqs
  end

  def build_hash
    Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
  end

  def get_actionofficer_ids_by_press_desk(pd_id)
    PressDesk.find(pd_id).action_officers.collect{|it| it.id}
  end
end
