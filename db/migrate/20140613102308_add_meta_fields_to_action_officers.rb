class AddMetaFieldsToActionOfficers < ActiveRecord::Migration[5.0]
  def change
    change_table :action_officers, bulk: true do |t|
      t.string  :phone
      t.integer :deputy_director_id
    end
  end
end
