# == Schema Information
#
# Table name: minister_contacts
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  email       :string(255)
#  phone       :string(255)
#  minister_id :integer
#  deleted     :boolean          default(FALSE)
#

class MinisterContact < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :email, uniqueness: true, on: :create
  validates_format_of :email,:with => Devise::email_regexp

  belongs_to :minister
end
