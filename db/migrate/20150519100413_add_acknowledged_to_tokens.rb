class AddAcknowledgedToTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :tokens, :acknowledged, :string
    add_column :tokens, :ack_time, :datetime
    add_index :tokens, :entity, unique: true
  end
end
