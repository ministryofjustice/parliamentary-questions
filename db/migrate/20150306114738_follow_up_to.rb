class FollowUpTo < ActiveRecord::Migration[5.0]
  def up
    add_column :pqs, 'follow_up_to', :string

    Pq.where("i_will_write = true AND uin like '%-IWW'").each do |pq|
      uin = pq.uin.gsub(/-IWW$/, '')
      pq.update_column(:follow_up_to, uin) if Pq.exists?(uin:)
    end
  end

  def down; end
end
