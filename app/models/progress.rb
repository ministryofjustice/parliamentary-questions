class Progress < ActiveRecord::Base
  has_many :pqs


  def classname
    self.name.downcase.sub ' ', '-'
  end

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

  def self.with_pod
    find_by_status(self.WITH_POD)
  end

  def self.pod_query
    find_by_status(self.POD_QUERY)
  end

  def self.pod_cleared
    find_by_status(self.POD_CLEARED)
  end

  def self.with_minister
    find_by_status(self.WITH_MINISTER)
  end

  def self.ministerial_query
    find_by_status(self.MINISTERIAL_QUERY)
  end

  def self.minister_cleared
    find_by_status(self.MINISTER_CLEARED)
  end



  # was

  def self.transfer
    find_by_status(self.TRANSFER)
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
    'Accepted'
  end

  def self.DRAFT_PENDING
    'Draft Pending'
  end

  def self.REJECTED
    'Rejected'
  end

  def self.WITH_POD
    'With POD'
  end

  def self.POD_QUERY
    'Pod Query'
  end

  def self.POD_CLEARED
    'Pod Cleared'
  end

  def self.WITH_MINISTER
    'With Minister'
  end

  def self.MINISTERIAL_QUERY
    'Ministerial Query'
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

  def self.TRANSFER
    'Transfer'
  end


  def self.new_questions
    [
        Progress.UNASSIGNED,
        Progress.NO_RESPONSE,
        Progress.ACCEPTED,
        Progress.REJECTED
    ]
  end

  def self.in_progress_questions
    [
        Progress.DRAFT_PENDING,
        Progress.WITH_POD,
        Progress.POD_QUERY,
        Progress.POD_CLEARED,
        Progress.WITH_MINISTER,
        Progress.MINISTERIAL_QUERY,
        Progress.MINISTER_CLEARED
    ]
  end

  def self.visible
    [new_questions, in_progress_questions].flatten
  end

end
