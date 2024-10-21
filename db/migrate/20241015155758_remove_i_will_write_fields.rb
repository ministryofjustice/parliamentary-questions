class RemoveIWillWriteFields < ActiveRecord::Migration[7.1]
  def up
    change_table :pqs, bulk: true do |t|
      t.remove :i_will_write
      t.remove :i_will_write_estimate
      t.remove :follow_up_to
    end
  end

  def down
    change_table :pqs, bulk: true do |t|
      t.boolean :i_will_write
      t.datetime :i_will_write_estimate, precision: nil
      t.string :follow_up_to
    end
  end
end
