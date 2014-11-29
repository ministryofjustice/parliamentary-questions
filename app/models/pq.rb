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

  has_one :trim_link, dependent: :destroy
  has_many :action_officers_pqs do
    def accepted
      where(response: 'accepted').first
    end

    def rejected
      where(response: 'rejected')
    end

    def all_rejected?
      all.find{ |assignment| !assignment.rejected? }.nil?
    end
  end
  has_many :action_officers, :through => :action_officers_pqs do
    def accepted
      where(action_officers_pqs: {response: 'accepted'}).first
    end

    def rejected
      where(action_officers_pqs: {response: 'rejected'})
    end
  end
  belongs_to :minister
  belongs_to :policy_minister, :class_name=>'Minister'
  belongs_to :progress
  belongs_to :transfer_out_ogd, :class_name=>'Ogd'
  belongs_to :transfer_in_ogd, :class_name=>'Ogd'
  belongs_to :directorate
  belongs_to :division


  accepts_nested_attributes_for :trim_link
  before_validation :strip_uin_whitespace

	validates :uin , presence: true, uniqueness:true
  validates :raising_member_id, presence:true
	validates :question, presence:true
  validates :final_response_info_released, inclusion: RESPONSES, allow_nil: true

  before_update :process_date_for_answer
  before_update :set_pod_waiting

  scope :allocated_since, ->(since) { joins(:action_officers_pqs).where('action_officers_pqs.updated_at >= ?', since).group('pqs.id').order(:uin) }
  scope :not_seen_by_finance, -> { where(seen_by_finance: false) }
  scope :accepted_in, ->(action_offiers) { joins(:action_officers_pqs).where(action_officers_pqs: { response: 'accepted', action_officer_id: action_officers }) }

  def reassign(action_officer)
    if action_officer.present? && action_officer_accepted != action_officer
      Pq.transaction do
        ao_pq_accepted.reset
        action_officers_pqs.find_or_create_by(action_officer: action_officer).accept
        whodunnit("AO:#{action_officer.name}") do
          division = action_officer.deputy_director.try(:division)
          directorate = division.try(:directorate)
          update(directorate: directorate, division: division)
        end
      end
    end
  end

  def self.ministers_by_progress(ministers, progresses)
    includes(:progress, :minister).
      where(progress_id: progresses).
      where(minister_id: ministers).
      group(:minister_id).
      group(:progress_id).
      count
  end

  def has_trim_link?
    trim_link.present? && !trim_link.deleted?
  end

  def strip_uin_whitespace
    self.uin = uin.strip.gsub(/\s/,'') if !uin.nil?
  end

  def commissioned?
    action_officers.size > 0 &&
        action_officers.rejected.size != action_officers.size
  end

  def only_rejected?
    action_officers.accepted.nil? && action_officers.rejected.any?
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
    action_officers.accepted
  end

  def ao_pq_accepted
    action_officers_pqs.accepted
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

  def deleted?
    !seen_by_finance?
  end

private

  def process_date_for_answer
    if self.date_for_answer.nil?
      self.date_for_answer_has_passed = true
      self.days_from_date_for_answer = LARGEST_POSTGRES_INTEGER
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
