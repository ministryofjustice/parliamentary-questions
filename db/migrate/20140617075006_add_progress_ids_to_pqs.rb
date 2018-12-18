class AddProgressIdsToPqs < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :progress_id, :integer
  end
end
