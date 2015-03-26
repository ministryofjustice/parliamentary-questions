module PQState
  UNASSIGNED        = 'unassigned'
  REJECTED          = 'rejected'
  NO_RESPONSE       = 'no_response'
  DRAFT_PENDING     = 'draft_pending'
  WITH_POD          = 'with_pod'
  POD_QUERY         = 'pod_query'
  POD_CLEARED       = 'pod_cleared'
  WITH_MINISTER     = 'with_minister'
  MINISTERIAL_QUERY = 'ministerial_query'
  MINISTER_CLEARED  = 'minister_cleared'
  ANSWERED          = 'answered'
  TRANSFERRED_OUT   = 'transferred_out'

  NEW = [
    UNASSIGNED,
    NO_RESPONSE,
    REJECTED
  ]

  IN_PROGRESS = [
    DRAFT_PENDING,
    WITH_POD,
    POD_QUERY,
    POD_CLEARED,
    WITH_MINISTER,
    MINISTERIAL_QUERY,
    MINISTER_CLEARED
  ]

  CLOSED = [
    ANSWERED,
    TRANSFERRED_OUT
  ]

  VISIBLE = NEW + IN_PROGRESS

  def self.state_weight(state)
    case state
    when UNASSIGNED, TRANSFERRED_OUT
      0
    when REJECTED, NO_RESPONSE
      1
    when DRAFT_PENDING
      2
    when WITH_POD, POD_QUERY
      3
    when WITH_MINISTER, MINISTERIAL_QUERY
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
    when UNASSIGNED        then 'Unassigned'
    when REJECTED          then 'Rejected'
    when NO_RESPONSE       then 'No response'
    when DRAFT_PENDING     then 'Draft Pending'
    when WITH_POD          then 'With POD'
    when POD_QUERY         then 'POD Query'
    when POD_CLEARED       then 'POD Cleared'
    when WITH_MINISTER     then 'With Minister'
    when MINISTERIAL_QUERY then 'Ministerial Query'
    when MINISTER_CLEARED  then 'Minister Cleared'
    when ANSWERED          then 'Answered'
    when TRANSFERRED_OUT   then 'Transferred out'
    end
  end
end

require 'pq_state/transition'
require 'pq_state/state_machine'
require 'pq_state/progress_changer'
