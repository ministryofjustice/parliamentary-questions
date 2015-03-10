module PQState
  module_function

  ALLOWED = [
    :unassigned,
    :rejected,
    :no_response,
    :draft_pending,
    :with_pod,
    :pod_cleared,
    :with_minister,
    :ministerial_query,
    :minister_cleared,
    :answered
  ]

  FINAL_STATES = [
    :answered,
    :transferred_out
  ]

  def progress_changer
    @progress_changer ||= StateMachine.build(
      FINAL_STATES,

      ## Commissioning
      Transition(:unassigned, :no_response) do |pq|
        pq.action_officers_pqs.any?
      end,

      ## Rejecting
      Transition(:no_response, :rejected) do |pq|
        pq.rejected?
      end,

      Transition(:rejected, :no_response) do |pq|
        pq.no_response?
      end,

      ## Draft Pending
      Transition(:no_response, :draft_pending) do |pq|
        pq.action_officer_accepted.present?
      end,

      ## With POD
      Transition(:draft_pending, :with_pod) do |pq|
        !!pq.draft_answer_received
      end,

      ## POD Query
      Transition(:with_pod, :pod_query) do |pq|
        !!pq.pod_query_flag
      end,

      ## POD Clearance
      Transition.factory([:with_pod, :pod_query], [:pod_cleared]) do |pq|
        (pq.draft_answer_received || pq.pod_query_flag) && pq.pod_clearance
      end,

      ## With Minister
      Transition(:pod_cleared, :with_minister) do |pq|
        if !pq.policy_minister
          !!pq.sent_to_answering_minister
        else
          !!(pq.sent_to_answering_minister && pq.sent_to_policy_minister)
        end
      end,

      ## Minister Query
      Transition(:with_minister, :ministerial_query) do |pq|
        pq.answering_minister_query || pq.policy_minister_query
      end,

      ## Minister Cleared
      Transition.factory([:with_minister, :ministerial_query], [:minister_cleared]) do |pq|
        (!pq.policy_minister && pq.cleared_by_answering_minister) ||
          (pq.cleared_by_answering_minister && pq.cleared_by_policy_minister)
      end,

      ## Answered
      Transition(:minister_cleared, :answered) do |pq|
        pq.pq_withdrawn || pq.answer_submitted
      end,

      # Transferred out
      Transition.factory(ALLOWED - [:answered], [:transferred_out]) do |pq|
        pq.transfer_out_ogd_id && pq.transfer_out_date
      end
    )
  end

  def Transition(from, to, &block)
    Transition.new(from, to, block)
  end
end

