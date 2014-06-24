class Progress < ActiveRecord::Base
  has_many :pqs


  # status finders

  def self.find_by_status(status)
    Progress.find_by_name(status)
  end

  def self.allocated_accepted
    find_by_status(self.ALLOCATED_ACCEPTED)
  end

  def self.allocated_pending
    find_by_status(self.ALLOCATED_PENDING)
  end

  def self.unallocated
    find_by_status(self.UNALLOCATED)
  end

  def self.rejected
    find_by_status(self.REJECTED)
  end
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


  # status constants

  def self.ALLOCATED_ACCEPTED
    'Allocated Accepted'
  end

  def self.ALLOCATED_PENDING
    'Allocated Pending'
  end

  def self.UNALLOCATED
    'Unallocated'
  end

  def self.REJECTED
    'Rejected'
  end

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



end
