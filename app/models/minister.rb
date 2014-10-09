class Minister < ActiveRecord::Base

  before_validation :strip_whitespace

  has_many :pqs
  has_many :minister_contacts
  accepts_nested_attributes_for :minister_contacts,
                                :allow_destroy => true,
                                :reject_if     => :all_blank

  def email
    minister_contacts.where(deleted: false).pluck('email').join(';')
  end

  # ToDo this should probably be in a decorator / presenter
  def name_with_inactive_status
    self.name + (self.deleted ? ' - Inactive' : '')
  end

  def self.all_active
    Minister.where(deleted: false)
  end

  private

  def strip_whitespace
    self.name = self.name.strip unless self.name.nil?
  end

end
