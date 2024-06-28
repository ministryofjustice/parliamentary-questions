# == Schema Information
#
# Table name: deputy_directors
#
#  id          :integer          not null, primary key
#  name        :string
#  email       :string
#  division_id :integer
#  deleted     :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class DeputyDirector < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :division_id, presence: true
  validates :email, presence: true

  has_many :action_officers
  belongs_to :division

  scope :active_list, -> { where("deputy_directors.deleted = ? OR deputy_directors.deleted = ? AND deputy_directors.updated_at > ?", false, true, 2.days.ago) }
end
