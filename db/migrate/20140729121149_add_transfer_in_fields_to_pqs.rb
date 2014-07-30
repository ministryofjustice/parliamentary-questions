class AddTransferInFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :transfer_in_ogd_id, :integer
    add_column :pqs, :transfer_in_date, :datetime
  end
end
