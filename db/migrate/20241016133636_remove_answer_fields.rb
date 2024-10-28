class RemoveAnswerFields < ActiveRecord::Migration[7.1]
  def up
    change_table :pqs, bulk: true do |t|
      t.remove :library_deposit
      t.remove :holding_reply_flag
      t.remove :pq_withdrawn
    end
  end

  def down
    change_table :pqs, bulk: true do |t|
      t.boolean :library_deposit
      t.boolean :holding_reply_flag
      t.datetime :pq_withdrawn
    end
  end
end
