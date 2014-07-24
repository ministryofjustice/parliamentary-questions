class PQ < ActiveRecord::Base
	validates :uin , presence: true, uniqueness:true
	validates :raising_member_id, presence:true
	validates :question, presence:true

  has_many :trim_links
    has_many :action_officers_pq
    has_many :action_officers, :through => :action_officers_pq
    belongs_to :minister #no link seems to be needed for policy_minister_id!?
    belongs_to :policy_minister, :class_name=>'Minister', :foreign_key=>'policy_minister_id'
 	#validates :finance_interest, :inclusion => {:in => [true, false]}, if: :seen_by_finance
  belongs_to :progress
  after_initialize :init

  def init
    self.seen_by_finance ||= false           #will set the default value only if it's nil
  end

  def is_in_progress?(pro)
    progress_id == pro.id
  end

  def action_officer_accepted
    action_officers_pq.each do |ao_pq|
      if ao_pq.accept
        return ao_pq.action_officer
      end
    end
    return nil
  end

  def self.new_questions()
    monitor_new_questions
    new_questions_internal
  end

  def self.in_progress()
    monitor_in_progress_questions
    in_progress_internal
  end

  def short_house_name
    if house_name.include?('Lords')
      'HoL'
    else
      'HoC'
    end
  end

  def self.not_seen_by_finance()
    where('seen_by_finance = ?', false)
  end


  # status queries
  # accepts an string
  #  -> by_status(Progress.ALLOCATED_ACCEPTED)
  # or an array
  #  -> by_status([Progress.ALLOCATED_ACCEPTED, Progress.ALLOCATED_PENDING])
  def self.by_status(status)
    monitor_questions_by_status(status)
    by_status_internal(status)
  end

  def self.allocated_accepted()
    by_status(Progress.ACCEPTED)
  end
  def self.no_response()
    by_status(Progress.NO_RESPONSE)
  end
  def self.unassigned()
    by_status(Progress.UNASSIGNED)
  end
  def self.rejected
    by_status(Progress.REJECTED)
  end
  def self.transfer
    by_status(Progress.TRANSFER)
  end
  def self.draft_pending
    by_status(Progress.DRAFT_PENDING)
  end
  def self.with_pod
    by_status(Progress.WITH_POD)
  end
  def self.pod_query
    by_status(Progress.POD_QUERY)
  end
  def self.pod_cleared
    by_status(Progress.POD_CLEARED)
  end
  def self.with_minister
    by_status(Progress.WITH_MINISTER)
  end
  def self.ministerial_query
    by_status(Progress.MINISTERIAL_QUERY)
  end
  def self.minister_cleared
    by_status(Progress.MINISTER_CLEARED)
  end
  def self.answered
    by_status(Progress.ANSWERED)
  end


  def self.transferred
    joins(:progress).where('pqs.transferred = true AND progresses.name != ?', Progress.ANSWERED)
  end

  def self.i_will_write_flag
    joins(:progress).where('pqs.i_will_write = true AND progresses.name != ?', Progress.ANSWERED)
  end


  private

  def self.by_status_internal(status)
    joins(:progress).where(progresses: {name: status})
  end


  def self.new_questions_internal()
    by_status(Progress.new_questions)
  end

  def self.in_progress_internal()
    by_status(Progress.in_progress_questions)
  end

  def self.monitor_new_questions
    number_of_questions = new_questions_internal.count
    $statsd.gauge("#{StatsHelper::PROGRESS}.new_questions", number_of_questions)
  end

  def self.monitor_in_progress_questions
    number_of_questions = in_progress_internal.count
    $statsd.gauge("#{StatsHelper::PROGRESS}.in_progress", number_of_questions)
  end

  def self.monitor_questions_by_status(status)
    # monitor the number of questions, if you query one status only
    if status.kind_of?(Array)
      return
    end

    # count it is use in the dashboard, so it hits the cache
    number_of_questions = by_status_internal(status).count
    key = status.underscore.gsub(' ', '_')
    $statsd.gauge("#{StatsHelper::PROGRESS}.#{key}", number_of_questions)
  end


end
