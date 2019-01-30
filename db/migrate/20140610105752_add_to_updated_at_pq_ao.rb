class AddToUpdatedAtPqAo < ActiveRecord::Migration[5.0]
  def change
    change_table :action_officers_pqs, bulk: true do |t|
      t.datetime :updated_at
      t.datetime :created_at
    end
  end
end
