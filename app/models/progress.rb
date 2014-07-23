class Progress < ActiveRecord::Base
  has_many :pqs


  # status finders

  def self.find_by_status(status)
    Progress.find_by_name(status)
  end

  def self.unassigned
    find_by_status(self.UNASSIGNED)
  end

  def self.no_response
    find_by_status(self.NO_RESPONSE)
  end

  def self.accepted
    find_by_status(self.ACCEPTED)
  end

  def self.draft_pending
    find_by_status(self.DRAFT_PENDING)
  end

  def self.rejected
    find_by_status(self.REJECTED)
  end
  # was





  def self.transfer
    find_by_status(self.TRANSFER)
  end
  def self.pod_waiting
    find_by_status(self.POD_WAITING)
  end
  def self.pod_query
    find_by_status(self.POD_QUERY)
  end
  def self.pod_cleared
    find_by_status(self.POD_CLEARED)
  end
  def self.minister_waiting
    find_by_status(self.MINISTER_WAITING)
  end
  def self.minister_query
    find_by_status(self.MINISTER_QUERY)
  end
  def self.minister_cleared
    find_by_status(self.MINISTER_CLEARED)
  end
  def self.answered
    find_by_status(self.ANSWERED)
  end
  def self.transferred_out
    find_by_status(self.TRANSFERRED_OUT)
  end

  # status constants
  def self.UNASSIGNED
    'Unassigned'
  end

  def self.NO_RESPONSE
    'No response'
  end

  def self.ACCEPTED
    'PQ Accepted'
  end

  def self.DRAFT_PENDING
    'Draft Pending'
  end

  def self.REJECTED
    'PQ Rejected'
  end
  # WAS






  def self.TRANSFER
    'Transfer'
  end



  def self.POD_WAITING
    'Pod Waiting'
  end

  def self.POD_QUERY
    'Pod Query'
  end

  def self.POD_CLEARED
    'Pod Cleared'
  end

  def self.MINISTER_WAITING
    'Minister Waiting'
  end

  def self.MINISTER_QUERY
    'Minister Query'
  end

  def self.MINISTER_CLEARED
    'Minister Cleared'
  end

  def self.ANSWERED
    'Answered'
  end

  def self.TRANSFERRED_OUT
    'Transferred out'
  end



end
