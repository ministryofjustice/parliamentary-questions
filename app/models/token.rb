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

  validates :acknowledged, inclusion: { in: %w(accept reject),  message: "%{value} is not a valid value for acknowledged" }, allow_nil: true


  def self.entity(entity_value)
    self.where(entity: entity_value).first
  end


  def self.assignment_stats(date = Date.today)
    recs = self.where('created_at > ? and created_at < ?', date.beginning_of_day, date.end_of_day)
    acks = recs.select{ |r| r.acknowledged? }
    
    { 
      total: recs.size, 
      ack: acks.size, 
      open: recs.size - acks.size, 
      pctg: (acks.size.to_f / (recs.size.nonzero? || 1).to_f * 100).round(2) 
    }
  end


  def accept
    acknowledge('accept')
  end

  def reject
    acknowledge('reject')
  end

  def acknowledged?
    self.acknowledged != nil
  end



  private

  def acknowledge(text)
    self.update_attributes acknowledged: text, ack_time: Time.now
  end
end
