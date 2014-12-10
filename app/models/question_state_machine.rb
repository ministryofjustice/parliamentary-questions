class QuestionStateMachine
  STATES = [
    :with_finance,
    :uncommissioned,
    :with_officers,
    :rejected,
    :transferred_out,
    :draft_pending,
    :with_pod,
    :pod_cleared,
    :with_policy_minister,
    :policy_minister_cleared,
    :with_answering_minister,
    :cleared,
    :answered,
    :withdrawn
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
  transition :uncommissioned, :with_officers, if: [:action_officers_present]
  transition :with_officers, :rejected, if: [:all_action_officers_rejected]
  transition :with_officers, :draft_pending, if: [:accepted_action_officer]
  transition :draft_pending, :with_pod, if: [:draft_answer_received]
  transition :with_pod, :pod_cleared, if: [:pod_clearance]
  transition :pod_cleared, :with_policy_minister, if: [:sent_to_policy_minister], required: [:policy_minister]
  transition :pod_cleared, :with_answering_minister, if: [:sent_to_answering_minister], required: [:no_policy_minister]
  transition :with_policy_minister, :policy_minister_cleared, if: [:cleared_by_policy_minister]
  transition :policy_minister_cleared, :with_answering_minister, if: [:sent_to_answering_minister], required: [:policy_minister]
  transition :with_answering_minister, :cleared, if: [:cleared_by_answering_minister]
  transition :cleared, :answered, if: [:answer_submitted]
  transition :cleared, :withdrawn, if: [:pq_withdrawn]

  [:with_finance, :uncommissioned, :with_officers, :rejected].each do |state|
    transition state, :transferred_out, if: [:transfer_out_ogd_id, :transfer_out_date], reverse: false
  end

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
    [:with_finance, :with_officers, :rejected]
  end

  def self.in_progress
    [ :draft_pending,
      :with_pod,
      :pod_cleared,
      :with_policy_minister,
      :policy_minister_cleared,
      :with_answering_minister,
      :cleared
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

    transition.present? && (self.state = transition.to) && true
  end
end
