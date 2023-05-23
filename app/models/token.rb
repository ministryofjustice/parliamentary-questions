# == Schema Information
#
# Table name: tokens
#
#  id           :integer          not null, primary key
#  path         :string(255)
#  token_digest :string(255)
#  expire       :datetime
#  entity       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  acknowledged :string(255)
#  ack_time     :datetime
#

class Token < ActiveRecord::Base
  has_paper_trail

  validates :acknowledged, inclusion: { in: %w[accept reject], message: t('page.message.token_value_error') }, allow_nil: true

  def self.entity(entity_value)
    # where(entity: entity_value).first
    find_by(entity: entity_value)
  end

  def self.assignment_stats(date = Time.zone.today)
    recs = where('created_at > ? and created_at < ?', date.beginning_of_day, date.end_of_day)
    acks = recs.select(&:acknowledged?)
    {
      total: recs.size,
      ack: acks.size,
      open: recs.size - acks.size,
      pctg: (acks.size.to_f / (recs.size.nonzero? || 1) * 100).round(2)
      # pctg: (acks.size.to_f / (recs.size.nonzero? || 1).to_f * 100).round(2)
    }
  end

  # returns true if at least one person has acknowledged the watchlist token for the specified date, otherwise false
  # def self.watchlist_status(date = Time.zone.today)
  def self.watchlist_status
    rec = find_by(
      'path = ? and created_at >= ? and created_at <= ?',
      '/watchlist/dashboard',
      Time.zone.today.beginning_of_day,
      Time.zone.today.end_of_day
    )
    rec.acknowledged?
  end

  def accept
    acknowledge('accept')
  end

  def reject
    acknowledge('reject')
  end

  def acknowledged?
    acknowledged != nil
  end

  private

  def acknowledge(text)
    update acknowledged: text, ack_time: Time.now
  end
end
