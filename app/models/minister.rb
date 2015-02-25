class Minister < ActiveRecord::Base
  has_paper_trail
  before_validation :strip_whitespace

  has_many :pqs
  has_many :minister_contacts
  accepts_nested_attributes_for :minister_contacts,
                                :allow_destroy => true,
                                :reject_if     => :all_blank

  def contact_emails
    minister_contacts.where(deleted: false).pluck('email')
  end

  def name_with_inactive_status
    self.name + (self.deleted ? ' - Inactive' : '')
  end

  def self.active(minister = nil)
    table = Minister.arel_table
    arel = table[:deleted].eq(false)
    arel = arel.or(table[:id].eq(minister.id)) if minister
    where(arel)
  end

private

  def strip_whitespace
    self.name = self.name.strip unless self.name.nil?
  end
end
