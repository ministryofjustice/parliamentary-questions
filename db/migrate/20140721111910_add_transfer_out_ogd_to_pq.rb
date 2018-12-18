class AddTransferOutOgdToPq < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :transfer_out_ogd_id, :integer
    add_column :pqs, :transfer_out_date, :datetime
  end
end
