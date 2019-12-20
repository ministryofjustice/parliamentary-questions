# == Schema Information
#
# Table name: ogds
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  acronym    :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class Ogd < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :acronym, presence: true
  has_many :pqs
  scope :active_list, -> { where('ogds.deleted = ? OR ogds.deleted = ? AND ogds.updated_at > ?', false, true, 2.days.ago.to_datetime) }

  def self.by_name(name)
    where('name ILIKE :search OR acronym ILIKE :search', search: "%#{name.strip}%")
  end
end
