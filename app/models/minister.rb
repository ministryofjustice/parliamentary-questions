# == Schema Information
#
# Table name: ministers
#
#  id         :integer          not null, primary key
#  name       :string
#  title      :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :integer
#

class Minister < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  before_validation :strip_whitespace!

  has_many :pqs
  has_many :minister_contacts
  accepts_nested_attributes_for :minister_contacts,
                                allow_destroy: true,
                                reject_if: :all_blank

  def contact_emails
    minister_contacts.active.pluck("email")
  end

  def name_with_inactive_status
    name + (deleted ? " - Inactive" : "")
  end

  def self.active_or_having_id(minister_id = nil)
    table = Minister.arel_table
    arel = table[:deleted].eq(false)
    arel = arel.or(table[:id].eq(minister_id)) if minister_id
    where(arel)
  end

private

  def strip_whitespace!
    self.name = name.strip if name
  end

  scope :active_list, -> { where("deleted = ? OR deleted = ? AND updated_at > ?", false, true, 2.days.ago) }
end
