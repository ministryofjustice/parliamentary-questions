# == Schema Information
#
# Table name: watchlist_members
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WatchlistMember < ApplicationRecord
  extend SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, on: :create # rubocop:disable Rails/UniqueValidationWithoutIndex
  # validates_format_of :email, with: Devise.email_regexp
  validates :email, format: { with: Devise.email_regexp }
  scope :active_list, -> { where("watchlist_members.deleted = ? OR watchlist_members.deleted = ? AND watchlist_members.updated_at > ?", false, true, 2.days.ago) }

  before_validation Validators::Whitespace.new
end
