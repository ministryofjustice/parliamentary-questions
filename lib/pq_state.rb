module PqState
  UNASSIGNED        = "unassigned".freeze
  REJECTED          = "rejected".freeze
  NO_RESPONSE       = "no_response".freeze
  DRAFT_PENDING     = "draft_pending".freeze
  WITH_POD          = "with_pod".freeze
  POD_CLEARED       = "pod_cleared".freeze
  WITH_MINISTER     = "with_minister".freeze
  MINISTER_CLEARED  = "minister_cleared".freeze
  ANSWERED          = "answered".freeze
  TRANSFERRED_OUT   = "transferred_out".freeze

  NEW = [
    UNASSIGNED,
    NO_RESPONSE,
    REJECTED,
  ].freeze

  IN_PROGRESS = [
    DRAFT_PENDING,
    WITH_POD,
    POD_CLEARED,
    WITH_MINISTER,
    MINISTER_CLEARED,
  ].freeze

  CLOSED = [
    ANSWERED,
    TRANSFERRED_OUT,
  ].freeze

  ALL = [
    UNASSIGNED,
    NO_RESPONSE,
    REJECTED,
    DRAFT_PENDING,
    WITH_POD,
    POD_CLEARED,
    WITH_MINISTER,
    MINISTER_CLEARED,
    ANSWERED,
    TRANSFERRED_OUT,
  ].freeze

  VISIBLE = NEW + IN_PROGRESS

  def self.state_weight(state)
    case state
    when UNASSIGNED, TRANSFERRED_OUT
      0
    when REJECTED, NO_RESPONSE
      1
    when DRAFT_PENDING
      2
    when WITH_POD
      3
    when WITH_MINISTER
      4
    when POD_CLEARED
      5
    when MINISTER_CLEARED
      6
    when ANSWERED
      7
    else
      0
    end
  end

  def self.state_label(state)
    case state
    when UNASSIGNED        then "Unassigned"
    when REJECTED          then "Rejected"
    when NO_RESPONSE       then "No response"
    when DRAFT_PENDING     then "Draft Pending"
    when WITH_POD          then "With POD"
    when POD_CLEARED       then "POD Cleared"
    when WITH_MINISTER     then "With Minister"
    when MINISTER_CLEARED  then "Minister Cleared"
    when ANSWERED          then "Answered"
    when TRANSFERRED_OUT   then "Transferred out"
    end
  end

  def self.progress_changer
    @progress_changer ||= StateMachine.build(
      CLOSED,
      ## Commissioning
      Transition(UNASSIGNED, NO_RESPONSE) do |pq|
        pq.action_officers_pqs.any?
      end,
      ## Rejecting
      Transition(NO_RESPONSE, REJECTED, &:rejected?),
      Transition(REJECTED, NO_RESPONSE, &:no_response?),
      ## Draft Pending
      Transition(NO_RESPONSE, DRAFT_PENDING) do |pq|
        pq.action_officer_accepted.present?
      end,
      ## With POD
      Transition(DRAFT_PENDING, WITH_POD) do |pq|
        !!pq.draft_answer_received # rubocop:disable Style/DoubleNegation
      end,
      ## POD Clearance
      Transition.factory([WITH_POD], [POD_CLEARED]) do |pq|
        pq.draft_answer_received && pq.pod_clearance
      end,
      ## With Minister
      Transition(POD_CLEARED, WITH_MINISTER) do |pq|
        if !pq.policy_minister
          !!pq.sent_to_answering_minister # rubocop:disable Style/DoubleNegation
        else
          !!(pq.sent_to_answering_minister && pq.sent_to_policy_minister) # rubocop:disable Style/DoubleNegation
        end
      end,
      ## Minister Cleared
      Transition.factory([WITH_MINISTER], [MINISTER_CLEARED]) do |pq|
        (!pq.policy_minister && pq.cleared_by_answering_minister) ||
          (pq.cleared_by_answering_minister && pq.cleared_by_policy_minister)
      end,
      ## Answered
      Transition(MINISTER_CLEARED, ANSWERED, &:answer_submitted),
      # Transferred out
      Transition.factory(ALL - CLOSED, [TRANSFERRED_OUT]) do |pq|
        pq.transfer_out_ogd_id && pq.transfer_out_date
      end,
    )
  end

  def self.Transition(from, to, &block) # rubocop:disable Naming/MethodName
    Transition.new(from, to, block)
  end
end
