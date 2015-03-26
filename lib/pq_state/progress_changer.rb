module PQState
  module_function

  ALLOWED = [
    UNASSIGNED,
    REJECTED,
    NO_RESPONSE,
    DRAFT_PENDING,
    WITH_POD,
    POD_CLEARED,
    WITH_MINISTER,
    MINISTERIAL_QUERY,
    MINISTER_CLEARED,
    ANSWERED
  ]

  FINAL_STATES = [
    ANSWERED,
    TRANSFERRED_OUT
  ]

  def progress_changer
    @progress_changer ||= StateMachine.build(
      FINAL_STATES,

      ## Commissioning
      Transition(UNASSIGNED, NO_RESPONSE) do |pq|
        pq.action_officers_pqs.any?
      end,

      ## Rejecting
      Transition(NO_RESPONSE, REJECTED) do |pq|
        pq.rejected?
      end,

      Transition(REJECTED, NO_RESPONSE) do |pq|
        pq.no_response?
      end,

      ## Draft Pending
      Transition(NO_RESPONSE, DRAFT_PENDING) do |pq|
        pq.action_officer_accepted.present?
      end,

      ## With POD
      Transition(DRAFT_PENDING, WITH_POD) do |pq|
        !!pq.draft_answer_received
      end,

      ## POD Query
      Transition(WITH_POD, POD_QUERY) do |pq|
        !!pq.pod_query_flag
      end,

      ## POD Clearance
      Transition.factory([WITH_POD, POD_QUERY], [POD_CLEARED]) do |pq|
        (pq.draft_answer_received || pq.pod_query_flag) && pq.pod_clearance
      end,

      ## With Minister
      Transition(POD_CLEARED, WITH_MINISTER) do |pq|
        if !pq.policy_minister
          !!pq.sent_to_answering_minister
        else
          !!(pq.sent_to_answering_minister && pq.sent_to_policy_minister)
        end
      end,

      ## Minister Query
      Transition(WITH_MINISTER, MINISTERIAL_QUERY) do |pq|
        pq.answering_minister_query || pq.policy_minister_query
      end,

      ## Minister Cleared
      Transition.factory([WITH_MINISTER, MINISTERIAL_QUERY], [MINISTER_CLEARED]) do |pq|
        (!pq.policy_minister && pq.cleared_by_answering_minister) ||
          (pq.cleared_by_answering_minister && pq.cleared_by_policy_minister)
      end,

      ## Answered
      Transition(MINISTER_CLEARED, ANSWERED) do |pq|
        pq.pq_withdrawn || pq.answer_submitted
      end,

      # Transferred out
      Transition.factory(ALLOWED - [ANSWERED], [TRANSFERRED_OUT]) do |pq|
        pq.transfer_out_ogd_id && pq.transfer_out_date
      end
    )
  end

  def Transition(from, to, &block)
    Transition.new(from, to, block)
  end
end

