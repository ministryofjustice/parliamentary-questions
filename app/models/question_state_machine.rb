class QuestionStateMachine
  STATES = [
    :with_finance,
    :uncommissioned,
    :awaiting_response,
    :rejected,
    :draft_pending,
    :with_pod,
    :with_pod_official,
    :pod_cleared,
    :with_policy_minister,
    :policy_minister_cleared,
    :with_answering_minister,
    :answering_minister_cleared,
    :answered,
    :withdrawn,
    :transferred_out
  ].freeze

  class Transition < Struct.new(:from, :to, :dependents, :requirements, :reverse)
    def ==(other)
      from == other.from && to == other.to
    end
  end

  def self.transitions
    @transitions ||= []
  end

  def self.reverse_transitions
    @reverse_transition ||= []
  end

  def self.transition from, to, options
    transitions << Transition.new(from, to, options[:if], options[:required] || [], false)

    unless options[:reverse] == false
      reverse_transitions.unshift Transition.new(to, from, options[:if], options[:required] || [], true)
    end
  end

  transition :with_finance, :uncommissioned, if: [:seen_by_finance]
  transition :uncommissioned, :awaiting_response, if: [:action_officers_present]
  transition :awaiting_response, :rejected, if: [:all_action_officers_rejected]
  transition :awaiting_response, :draft_pending, if: [:accepted_action_officer]
  transition :draft_pending, :with_pod, if: [:draft_answer_received]
  transition :with_pod, :pod_cleared, if: [:pod_clearance]
  transition :with_pod, :with_pod_official, if: [:pod_official_interest]
  transition :with_pod_official, :pod_cleared, if: [:pod_clearance], required: [:pod_official_interest]
  transition :pod_cleared, :with_policy_minister, if: [:sent_to_policy_minister], required: [:policy_minister]
  transition :pod_cleared, :with_answering_minister, if: [:sent_to_answering_minister]
  transition :with_policy_minister, :policy_minister_cleared, if: [:cleared_by_policy_minister]
  transition :policy_minister_cleared, :with_answering_minister, if: [:sent_to_answering_minister], required: [:policy_minister]
  transition :with_answering_minister, :answering_minister_cleared, if: [:cleared_by_answering_minister]
  transition :answering_minister_cleared, :answered, if: [:answer_submitted]
  transition :answering_minister_cleared, :withdrawn, if: [:pq_withdrawn]

  [:uncommissioned, :awaiting_response, :rejected].each do |state|
    transition state, :transferred_out, if: [:transfer_out_ogd_id, :transfer_out_date], reverse: false
  end
  transition :with_finance, :transferred_out, if: [:transfer_out_ogd_id, :transfer_out_date]

  def self.indexes_for(*states)
    states.flatten.map{|state| index_for(state) }
  end

  def self.index_for(state)
    STATES.index(state) || raise("Unknown state '#{state}' in QuestionStateMachine")
  end

  def self.include?(state)
    STATES.include?(state)
  end

  def self.new_questions
    [:with_finance, :uncommissioned, :awaiting_response, :rejected]
  end

  def self.in_progress
    [ :draft_pending,
      :with_pod,
      :with_pod_official,
      :pod_cleared,
      :with_policy_minister,
      :policy_minister_cleared,
      :with_answering_minister,
      :answering_minister_cleared
    ]
  end

  def self.closed
    [:withdrawn, :answered, :transferred_out]
  end

  def self.visible
    new_questions + in_progress
  end

  def initialize(model)
    @model = model
    @state = @model.state
  end

  def state
    STATES[@state] if @state
  end

  def state=(new_state)
    @state = self.class.index_for(new_state)
  end

  def index
    @state
  end

  def new_question?
    self.class.new_questions.include?(state)
  end

  def closed?
    self.class.closed.include?(state)
  end

  def available_transitions
    transitions = self.class.transitions + self.class.reverse_transitions
    transitions.select{|transition| transition.from == state }
  end

  def transition
    errors = ActiveModel::Errors.new(@model)
    @model.run_callbacks(:validation)
    transition = available_transitions.find do |transition|
      errors.clear
      method = transition.reverse ? :present : :blank
      transition.dependents.each do |dependent|
        if @model.send(dependent).send(:"#{method}?")
          errors.add(dependent, method)
        end
      end
      transition.requirements.each do |requirement|
        if @model.send(requirement).blank?
          errors.add(requirement, :blank)
        end
      end
      errors.empty?
    end

    self.state = transition.to and true if transition.present?
  end
end
