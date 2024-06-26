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
  scope :active_list, -> { where("early_bird_members.deleted = ? OR early_bird_members.deleted = ? AND early_bird_members.updated_at > ?", false, true, 2.days.ago) }
  before_validation Validators::Whitespace.new
end
