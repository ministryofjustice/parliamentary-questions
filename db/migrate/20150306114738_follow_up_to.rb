class FollowUpTo < ActiveRecord::Migration
  def up
    add_column :pqs, "follow_up_to", :string

    Pq.where("i_will_write = true AND uin like '%-IWW'").each do |pq|
      uin = pq.uin.gsub(/-IWW$/, '')
      if Pq.exists?(uin: uin)
        pq.update_column(:follow_up_to, uin)
      end
    end
  end

  def down
  end
end
