# == Schema Information
#
# Table name: ministers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  member_id  :integer
#

class Minister < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  before_validation :strip_whitespace!

  has_many :pqs
  has_many :minister_contacts
  accepts_nested_attributes_for :minister_contacts,
                                :allow_destroy => true,
                                :reject_if     => :all_blank

  def contact_emails
    minister_contacts.active.pluck('email')
  end

  def name_with_inactive_status
    self.name + (self.deleted ? ' - Inactive' : '')
  end

  def self.active_or_having_id(minister_id = nil)
    table = Minister.arel_table
    arel = table[:deleted].eq(false)
    arel = arel.or(table[:id].eq(minister_id)) if minister_id
    where(arel)
  end

  private

  def strip_whitespace!
    self.name = self.name.strip if self.name
  end
end
