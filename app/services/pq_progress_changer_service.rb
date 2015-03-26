class PQProgressChangerService
  def update_progress(pq)
    new_state   = PQState.progress_changer.next_state(PQState::UNASSIGNED, pq)
    pq.state    = new_state
    pq.progress = conversions.fetch(new_state)
    pq.save!
  end

  private

  def conversions
    @conversions ||= {
      PQState::UNASSIGNED        => Progress.unassigned,
      PQState::REJECTED          => Progress.rejected,
      PQState::NO_RESPONSE       => Progress.no_response,
      PQState::DRAFT_PENDING     => Progress.draft_pending,
      PQState::WITH_POD          => Progress.with_pod,
      PQState::POD_QUERY         => Progress.pod_query,
      PQState::POD_CLEARED       => Progress.pod_cleared,
      PQState::WITH_MINISTER     => Progress.with_minister,
      PQState::MINISTERIAL_QUERY => Progress.ministerial_query,
      PQState::MINISTER_CLEARED  => Progress.minister_cleared,
      PQState::ANSWERED          => Progress.answered,
      PQState::TRANSFERRED_OUT   => Progress.transferred_out
    }
  end
end
