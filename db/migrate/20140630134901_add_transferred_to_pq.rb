class AddTransferredToPq < ActiveRecord::Migration
  def change
    add_column :pqs, :transferred, :boolean
  end
end
