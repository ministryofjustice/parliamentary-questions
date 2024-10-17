# == Schema Information
#
# Table name: tokens
#
#  id           :integer          not null, primary key
#  path         :string
#  token_digest :string
#  expire       :datetime
#  entity       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  acknowledged :string
#  ack_time     :datetime
#

class Token < ApplicationRecord
  has_paper_trail

  validates :acknowledged, inclusion: { in: %w[accept reject], message: "%{value} is not a valid value for acknowledged" }, allow_nil: true

  def self.entity(entity_value)
    # where(entity: entity_value).first
    find_by(entity: entity_value)
  end

  def self.assignment_stats(date = Time.zone.today)
    recs = where("created_at > ? and created_at < ?", date.beginning_of_day, date.end_of_day)
    acks = recs.select(&:acknowledged?)
    {
      total: recs.size,
      ack: acks.size,
      open: recs.size - acks.size,
      pctg: (acks.size.to_f / (recs.size.nonzero? || 1) * 100).round(2),
      # pctg: (acks.size.to_f / (recs.size.nonzero? || 1).to_f * 100).round(2)
    }
  end

  def accept
    acknowledge("accept")
  end

  def reject
    acknowledge("reject")
  end

  def acknowledged?
    acknowledged != nil
  end

private

  def acknowledge(text)
    update acknowledged: text, ack_time: Time.zone.now
  end
end
