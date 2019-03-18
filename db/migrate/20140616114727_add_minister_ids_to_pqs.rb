class AddMinisterIdsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.integer :minister_id
      t.integer :policy_minister_id
    end
  end
end
