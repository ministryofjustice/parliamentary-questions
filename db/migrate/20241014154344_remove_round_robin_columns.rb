class RemoveRoundRobinColumns < ActiveRecord::Migration[7.1]
  def up
    change_table :pqs, bulk: true do |t|
      t.remove :round_robin
      t.remove :round_robin_date
      t.remove :round_robin_guidance_received
    end
  end

  def down
    change_table :pqs, bulk: true do |t|
      t.boolean :round_robin
      t.datetime :round_robin_date
      t.datetime :round_robin_guidance_received
    end
  end
end
