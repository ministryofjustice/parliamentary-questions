class ReportsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  @@per_page = 10

  def ministers_by_progress
    @p = Progress.where(name: Progress.in_progress_questions)
    @m = Minister.where(deleted: false)

    @counters = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }

    @m.each do |m|
      # calculate the counters
      @p.each do |p|
        @counters[m.id][p.id] = PQ_by_minister(m.id).where('progress_id = ?', p.id).count
      end
    end
  end


  def press_desk_by_progress
    @p = Progress.all
    @pd = PressDesk.where(deleted: false)

    # auto-vivifying Hash (http://trevoke.net/blog/2009/11/06/auto-vivifying-hashes-in-ruby/)
    @counters = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }

    @pd.each do |pd|
      # collect Action Officers Ids
      aos = pd.action_officers.collect{|it| it.id}
      # calculate the counters
      @p.each do |p|
        @counters[pd.id][p.id] = PQ_by_press_desk(aos).where('progress_id = ?', p.id).count
      end
    end
  end

  def ministers_filter
    minister_id = params[:minister_id]
    progress_id = params[:progress_id]
    @progresses = []

    if minister_id.nil? || minister_id.empty?
      return render action: 'ministers_filter', minister_id: minister_id, progress_id: progress_id
    end

    progress_counters = PQ_by_minister(minister_id).group('progress_id').count

    Progress.all.each do |it|
      count = progress_counters[it.id] || 0
      @progresses.push({id: it.id, name: it.name, count: count})
    end

    if !progress_id.nil? && !progress_id.empty?
      pqs = PQ_by_minister(minister_id).where('progress_id = ? ', progress_id)
    else
      pqs = PQ_by_minister(minister_id)
    end

    @questions_count = pqs.count
    @questions = pqs.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load

    render action: 'ministers_filter', minister_id: minister_id, progress_id: progress_id
  end

  def press_desk_filter
    press_desk_id = params[:press_desk_id]
    progress_id = params[:progress_id]
    @progresses = []

    if press_desk_id.nil? || press_desk_id.empty?
      return render action: 'press_desk_filter', press_desk_id: press_desk_id, progress_id: progress_id
    end

    aos = PressDesk.find(press_desk_id).action_officers.collect{|it| it.id}

    Progress.all.each do |it|
      count = PQ_by_press_desk(aos).where('progress_id = ?', it.id).count
      @progresses.push({id: it.id, name: it.name, count: count})
    end

    if !progress_id.nil? && !progress_id.empty?
      pqs = PQ_by_press_desk(aos).where('progress_id = ?', progress_id)
    else
      pqs = PQ_by_press_desk(aos)
    end

    @questions_count = pqs.count
    @questions = pqs.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load

    render action: 'press_desk_filter', press_desk_id: press_desk_id, progress_id: progress_id
  end

  def filter_all
    minister_id = params[:minister_id]
    press_desk_id = params[:press_desk_id]
    progress_id = params[:progress_id]


    aos = PressDesk.find(press_desk_id).action_officers.collect{|it| it.id} unless press_desk_id.blank?
    if !minister_id.blank? || !press_desk_id.blank? || !progress_id.blank?
      pqs = PQ_by_all(aos,minister_id,progress_id)
      @questions_count = pqs.count
      @questions = pqs.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
    end
  render action: 'filter_all', press_desk_id: press_desk_id, progress_id: progress_id, minister_id: minister_id
  end

  def PQ_by_press_desk(aos)
    Pq.joins(:action_officers_pq).where('action_officers_pqs.accept = true AND action_officers_pqs.action_officer_id IN (:ao)', ao: aos)
  end

  def PQ_by_minister(minister_id)
    Pq.where('minister_id = :m_id OR policy_minister_id = :m_id', m_id: minister_id)
  end

  def PQ_by_all(aos, minister_id, progress_id)

    @Pqs = Pq

    if !minister_id.blank?
      @Pqs = @Pqs.where('minister_id = :m_id OR policy_minister_id = :m_id', m_id: minister_id)
    end

    if !aos.nil?
      @Pqs = @Pqs.joins(:action_officers_pq).where('action_officers_pqs.accept = true AND action_officers_pqs.action_officer_id IN (:ao)', ao: aos)
    end
    if !progress_id.blank?
      @Pqs = @Pqs.where('progress_id = :p_id', p_id:progress_id)
    end
    @Pqs
  end


end
