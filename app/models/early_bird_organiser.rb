# == Schema Information
#
# Table name: early_bird_organisers
#
#  id         :bigint           not null, primary key
#  date_from  :date
#  date_to    :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EarlyBirdOrganiser < ApplicationRecord
  validates :date_from, presence: true
  validates :date_to, presence: true

  validate :date_to_cant_be_before_date_from

  validate :date_from_must_not_be_in_the_past

private

  # rubocop:disable Style/RedundantParentheses
  def date_to_cant_be_before_date_from
    if (date_to && date_from) && (date_to < date_from)
      errors.add(:date_to, "cannot be before the First date")
    end
  end
  # rubocop:enable Style/RedundantParentheses

  def date_from_must_not_be_in_the_past
    if date_from && date_from < Time.zone.today
      errors.add(:date_from, "cannot be in the past")
    end
  end
end
