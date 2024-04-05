module PqState
  UNASSIGNED        = "unassigned".freeze
  REJECTED          = "rejected".freeze
  NO_RESPONSE       = "no_response".freeze
  DRAFT_PENDING     = "draft_pending".freeze
  WITH_POD          = "with_pod".freeze
  POD_QUERY         = "pod_query".freeze
  POD_CLEARED       = "pod_cleared".freeze
  WITH_MINISTER     = "with_minister".freeze
  MINISTERIAL_QUERY = "ministerial_query".freeze
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
    POD_QUERY,
    POD_CLEARED,
    WITH_MINISTER,
    MINISTERIAL_QUERY,
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
    POD_QUERY,
    POD_CLEARED,
    WITH_MINISTER,
    MINISTERIAL_QUERY,
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
    when UNASSIGNED        then "Unassigned"
    when REJECTED          then "Rejected"
    when NO_RESPONSE       then "No response"
    when DRAFT_PENDING     then "Draft Pending"
    when WITH_POD          then "With POD"
    when POD_QUERY         then "POD Query"
    when POD_CLEARED       then "POD Cleared"
    when WITH_MINISTER     then "With Minister"
    when MINISTERIAL_QUERY then "Ministerial Query"
    when MINISTER_CLEARED  then "Minister Cleared"
    when ANSWERED          then "Answered"
    when TRANSFERRED_OUT   then "Transferred out"
    end
  end
end
