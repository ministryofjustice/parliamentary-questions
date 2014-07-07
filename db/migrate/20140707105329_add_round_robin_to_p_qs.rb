class AddRoundRobinToPQs < ActiveRecord::Migration
  def change
    change_table :pqs do |t|
      t.boolean :round_robin
      t.datetime :round_robin_date
    end
  end
end
