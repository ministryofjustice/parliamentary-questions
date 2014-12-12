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

  attr_accessor :seen_by_finance,
    :action_officers_present,
    :all_action_officers_rejected,
    :pod_official_interest

  has_one :trim_link, dependent: :destroy
  has_many :action_officers_pqs do
    def accepted
      where(response: :accepted)
    end

    def rejected
      where(response: :rejected)
    end
  end
  has_many :action_officers, :through => :action_officers_pqs do
    def accepted
      where(action_officers_pqs: {response: :accepted})
    end

    def rejected
      where(action_officers_pqs: {response: :rejected})
    end
  end
  belongs_to :minister
  belongs_to :policy_minister, :class_name=>'Minister'
  belongs_to :transfer_out_ogd, :class_name=>'Ogd'
  belongs_to :transfer_in_ogd, :class_name=>'Ogd'
  belongs_to :directorate
  belongs_to :division

  accepts_nested_attributes_for :trim_link
  before_validation :sanitize_uin
  before_validation :set_non_model_attributes_for_transitions

  validates :uin , presence: true, uniqueness: true
  validates :raising_member_id, :text, presence: true
  validates :final_response_info_released, inclusion: RESPONSES, allow_nil: true

  before_update :process_date_for_answer
  before_save :transition_before_save
  before_save :set_state

  def set_state
    self[:state] = state_machine.index
  end

  scope :allocated_since, ->(since) { joins(:action_officers_pqs).
    where('action_officers_pqs.updated_at >= ?', since).group('pqs.id').order(:uin) }
  scope :accepted_in, ->(action_offiers) { joins(:action_officers_pqs).
    where(action_officers_pqs: { response: :accepted, action_officer_id: action_officers }) }
  scope :new_questions, -> { in_state(QuestionStateMachine.new_questions) }
  scope :in_progress, -> { in_state(QuestionStateMachine.in_progress) }

  def self.in_state(states)
    where(state: QuestionStateMachine.indexes_for(states))
  end

  def self.ministers_by_state(ministers, states)
    includes(:minister).
    where(state: QuestionStateMachine.indexes_for(states)).
    where(minister_id: ministers).
    group(:minister_id).
    group(:state).
    count.map{|key, count| [[key.first, QuestionStateMachine::STATES[key.second]], count]}.to_h
  end

  def state_machine
    @state_machine ||= QuestionStateMachine.new(self)
  end
  delegate :closed?, :new_question?, to: :state_machine

  def transition
    save
  end

  def reassign(action_officer)
    if action_officer.present? && accepted_action_officer != action_officer
      Pq.transaction do
        accepted_assignment.reset
        action_officers_pqs.find_or_create_by(action_officer: action_officer).accept
        whodunnit("AO:#{action_officer.name}") do
          division = action_officer.deputy_director.try(:division)
          directorate = division.try(:directorate)
          update(directorate: directorate, division: division)
        end
      end
    end
  end

  def accepted_action_officer
    action_officers.accepted.first
  end

  def accepted_assignment
    action_officers_pqs.accepted.first
  end

  def short_house_name
    if house_name.include?('Lords')
      'HoL'
    else
      'HoC'
    end
  end

  def has_trim_link?
    trim_link.present? && !trim_link.deleted?
  end

  def only_rejected?
    accepted_action_officer.nil? && action_officers.rejected.any?
  end

  def transferred_in?
    transfer_in_date.present?
  end

  def seen_by_finance
    {'0' => false, '1' => true, nil => !with_finance?}[@seen_by_finance]
  end

  def seen_by_finance?
    seen_by_finance
  end

  def pod_official_interest
    {'0' => false, '1' => true, nil => with_pod_official?}[@pod_official_interest]
  end

  def pod_official_interest?
    pod_official_interest
  end

  def open?
    !closed?
  end

  def deleted?
    !seen_by_finance?
  end

  def overdue_internally?
    open? && internal_deadline.try(:past?) && draft_answer_received.blank?
  end

  def overdue?
    open? && date_for_answer.try(:past?)
  end

  def past?(state)
    self[:state] > QuestionStateMachine.index_for(state)
  end

  QuestionStateMachine::STATES.each do |test_state|
    define_method(:"#{test_state}?") do
      state_machine.state == test_state
    end
  end

private

  def transition_before_save
    state_machine.transition
    true
  end

  def set_non_model_attributes_for_transitions
    self.action_officers_present = action_officers.any?
    self.all_action_officers_rejected = all_action_officers_rejected?
    true
  end

  def all_action_officers_rejected?
    return false if action_officers_pqs.empty?
    action_officers_pqs.find{ |assignment| !assignment.rejected? }.nil?
  end

  def sanitize_uin
    self.uin = uin.try(:gsub, ' ', '')
    true
  end

  def process_date_for_answer
    if self.date_for_answer.nil?
      self.date_for_answer_has_passed = true
      self.days_from_date_for_answer = LARGEST_POSTGRES_INTEGER
    else
      self.date_for_answer_has_passed = self.date_for_answer < Date.today
      self.days_from_date_for_answer = (self.date_for_answer - Date.today).abs
    end
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
