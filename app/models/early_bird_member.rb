# == Schema Information
#
# Table name: early_bird_members
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  deleted    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EarlyBirdMember < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, on: :create # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :email, format: { with: Devise.email_regexp }

  scope :active_list, -> { where(deleted: false) }
  scope :inactive_list, -> { where(deleted: true) }

  before_validation Validators::Whitespace.new
end
