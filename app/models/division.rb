# == Schema Information
#
# Table name: divisions
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  directorate_id :integer
#  deleted        :boolean          default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

class Division < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :directorate_id, presence: true
  has_many :deputy_directors do
    def active
      where(deleted: false)
    end
  end
  belongs_to :directorate
  scope :active_list, -> { where("divisions.deleted = ? OR divisions.deleted = ? AND divisions.updated_at > ?", false, true, 2.days.ago.to_datetime) }
end
