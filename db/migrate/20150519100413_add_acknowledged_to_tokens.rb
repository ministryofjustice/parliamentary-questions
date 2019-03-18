class AddAcknowledgedToTokens < ActiveRecord::Migration[5.0]
  def change
    change_table :tokens, bulk: true do |t|
      t.string   :acknowledged
      t.datetime :ack_time
      t.index    :entity, unique: true
    end
  end
end
