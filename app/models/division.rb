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

class Division < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :directorate_id, presence: true 
  has_many :deputy_directors
  belongs_to :directorate
end
