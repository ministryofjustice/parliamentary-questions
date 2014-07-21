class AddTransferOutOgdToPq < ActiveRecord::Migration
  def change
    add_column :pqs, :transfer_out_ogd_id, :integer
    add_column :pqs, :transfer_out_date, :datetime
  end
end
