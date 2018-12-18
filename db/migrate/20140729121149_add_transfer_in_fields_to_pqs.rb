class AddTransferInFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :transfer_in_ogd_id, :integer
    add_column :pqs, :transfer_in_date, :datetime
  end
end
