class Pq < ActiveRecord::Base
  has_paper_trail

  RESPONSES = [
    "Commercial in confidence",
    "Disproportionate cost",
    "Full disclosure",
    "Holding reply [named day PQ only]",
    "I will write",
    "Information not held centrally",
    "Information not recorded",
    "Partial disclosure",
    "Partial Disproportionate cost",
    "Referral"
  ]

  has_many :trim_links
  has_many :action_officers_pq
  has_many :action_officers, :through => :action_officers_pq
  belongs_to :minister
  belongs_to :policy_minister, :class_name=>'Minister'
  belongs_to :progress
  belongs_to :transfer_out_ogd, :class_name=>'Ogd'
  belongs_to :transfer_in_ogd, :class_name=>'Ogd'

  before_validation :strip_uin_whitespace

	validates :uin , presence: true, uniqueness:true
  validates :raising_member_id, presence:true
	validates :question, presence:true
  validates :final_response_info_released, inclusion: RESPONSES, allow_nil: true

  before_update :process_date_for_answer
  before_update :set_pod_waiting

  after_initialize :init

  scope :allocated_since, ->(since) { joins(:action_officers_pq).where('action_officers_pqs.updated_at >= ?', since).group('pqs.id').order(:uin) }
  scope :not_seen_by_finance, -> { where(seen_by_finance: false) }

  def self.ministers_by_progress(ministers, progresses)
    includes(:progress, :minister).
      where(progress_id: progresses).
      where(minister_id: ministers).
      group(:minister_id).
      group(:progress_id).
      count
  end

  def init
    self.seen_by_finance ||= false
  end

  def strip_uin_whitespace
    self.uin = uin.strip.gsub(/\s/,'') if !uin.nil?
  end

  def commissioned?
    action_officers_pq.size > 0 &&
        action_officers_pq.rejected.size != action_officers_pq.size
  end

  def rejected?
    if action_officers_pq.count > 0 &&  ao_pq_accepted.nil?
      action_officers_pq.each do |ao_pq|
        if ao_pq.reject
          return true
        end
      end
    end
    return false
  end

  def closed?
    unless progress.nil?
      Progress.closed_questions.include?(progress.name)
    else
      false
    end
  end

  def open?
    !closed?
  end

  def is_in_progress?(pro)
    progress_id == pro.id
  end

  def action_officer_accepted
    action_officers_pq.find(&:accept).try(:action_officer)
  end

  def ao_pq_accepted
    action_officers_pq.find(&:accept)
  end

  def self.new_questions()
    monitor_new_questions
    new_questions_internal
  end

  def self.in_progress()
    monitor_in_progress_questions
    in_progress_internal
  end

  def self.visibles()
    by_status_internal(Progress.visible)
  end

  def short_house_name
    if house_name.include?('Lords')
      'HoL'
    else
      'HoC'
    end
  end

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
    joins(:progress).where('pqs.transferred = true AND progresses.name IN (?)', Progress.new_questions)
  end

  def self.i_will_write_flag
    joins(:progress).where('pqs.i_will_write = true AND progresses.name NOT IN (?)', Progress.closed_questions)
  end

  def set_pod_waiting
    if self.draft_answer_received_changed?
      self.pod_waiting = draft_answer_received
    end
  end

  def active?
    seen_by_finance?
  end

private

  def process_date_for_answer
    if self.date_for_answer.nil?
      self.date_for_answer_has_passed = TRUE      # We don't know that it hasn't passed,so we want these at the very bottom of the sort...
      self.days_from_date_for_answer = 2147483647 # Biggest available Postgres Integer
    else
      self.date_for_answer_has_passed = self.date_for_answer < Date.today
      self.days_from_date_for_answer = (self.date_for_answer - Date.today).abs
    end
  end

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
    return if status.kind_of?(Array)

    number_of_questions = by_status_internal(status).count
    key = status.underscore.gsub(' ', '_')
    $statsd.gauge("#{StatsHelper::PROGRESS}.#{key}", number_of_questions)
  end
end
