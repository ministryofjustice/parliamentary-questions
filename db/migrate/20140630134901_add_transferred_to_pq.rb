class AddTransferredToPq < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :transferred, :boolean
  end
end
