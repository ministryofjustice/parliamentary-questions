class PQProgressChangerService

  CONVERSIONS = {
    unassigned: Progress.unassigned,
    rejected: Progress.rejected,
    no_response: Progress.no_response,
    draft_pending: Progress.draft_pending,
    with_pod: Progress.with_pod,
    pod_query: Progress.pod_query,
    pod_cleared: Progress.pod_cleared,
    with_minister: Progress.with_minister,
    ministerial_query: Progress.ministerial_query,
    minister_cleared: Progress.minister_cleared,
    answered: Progress.answered,
    transferred_out: Progress.transferred_out
  }

  def update_progress(pq)
    h           = CONVERSIONS
    new_state   = PQState.progress_changer.next_state(:unassigned, pq)
    pq.progress = h.fetch(new_state)
    pq.save!
  end
end
