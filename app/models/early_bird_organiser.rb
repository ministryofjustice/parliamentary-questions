class EarlyBirdOrganiser < ActiveRecord::Base
    
  validates :date_from, presence: true
  validates :date_to, presence: true

  validate :date_to_cant_be_before_date_from

  private

  def date_to_cant_be_before_date_from
    if date_to && date_from
      if date_to < date_from
        errors.add(:date_to, "cannot be before Date from")
      end
    else
        errors.add(:dates, "cannot be nil")
    end
  end
end
