class AddAcknowledgedToTokens < ActiveRecord::Migration
  def change
    add_column :tokens, :acknowledged, :string
    add_column :tokens, :ack_time, :datetime
    add_index :tokens, :entity, unique: true
  end
end
