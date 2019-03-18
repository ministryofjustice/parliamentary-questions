class AddTransferOutOgdToPq < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.integer  :transfer_out_ogd_id
      t.datetime :transfer_out_date
    end
  end
end
