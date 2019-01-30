class AddRoundRobinToPQs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.boolean :round_robin
      t.datetime :round_robin_date
    end
  end
end
