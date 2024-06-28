# == Schema Information
#
# Table name: minister_contacts
#
#  id          :integer          not null, primary key
#  name        :string
#  email       :string
#  phone       :string
#  minister_id :integer
#  deleted     :boolean          default(FALSE)
#

class MinisterContact < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :email, uniqueness: true, on: :create # rubocop:disable Rails/UniqueValidationWithoutIndex
  # validates_format_of :email, with: Devise.email_regexp
  validates :email, format: { with: Devise.email_regexp }

  belongs_to :minister
end
