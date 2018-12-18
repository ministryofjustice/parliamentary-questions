class PrimaryKeyForPqAo < ActiveRecord::Migration[5.0]
  def change
    add_column :action_officers_pqs, :id, :primary_key
  end
end
