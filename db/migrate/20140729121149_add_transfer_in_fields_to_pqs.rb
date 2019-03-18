class AddTransferInFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.integer  :transfer_in_ogd_id
      t.datetime :transfer_in_date
    end
  end
end
