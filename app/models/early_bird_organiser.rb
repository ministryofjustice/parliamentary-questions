class EarlyBirdOrganiser < ActiveRecord::Base
    
  validates :date_from, presence: true
  validates :date_to, presence: true

  validate :date_to_cant_be_before_date_from

  validate :date_from_must_not_be_in_the_past

  private

  def date_to_cant_be_before_date_from
    if (date_to && date_from) && (date_to < date_from)
      errors.add(:date_to, "cannot be before Date from")
    end
  end

  def date_from_must_not_be_in_the_past
    if date_from && date_from < Time.zone.today
      errors.add(:date_from, "cannot be in the past")
    end
  end
end
