# == Schema Information
#
# Table name: directorates
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class Directorate < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  has_many :divisions
  scope :active_list, -> { where("deleted = ? OR deleted = ? AND updated_at > ?", false, true, 2.days.ago.to_datetime) }
end
