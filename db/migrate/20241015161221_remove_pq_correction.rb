class RemovePqCorrection < ActiveRecord::Migration[7.1]
  def up
    change_table :pqs, bulk: true do |t|
      t.remove :pq_correction_received
      t.remove :correction_circulated_to_action_officer
    end
  end

  def down
    change_table :pqs, bulk: true do |t|
      t.boolean :pq_correction_received
      t.datetime :correction_circulated_to_action_officer, precision: nil
    end
  end
end
