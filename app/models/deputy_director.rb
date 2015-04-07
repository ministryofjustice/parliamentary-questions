# == Schema Information
#
# Table name: deputy_directors
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  email       :string(255)
#  division_id :integer
#  deleted     :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#

class DeputyDirector < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :division_id, presence: true
  validates :email, presence: true

  has_many :action_officers
  belongs_to :division
end
