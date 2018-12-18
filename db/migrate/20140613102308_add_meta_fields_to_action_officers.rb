class AddMetaFieldsToActionOfficers < ActiveRecord::Migration[5.0]
  def change
    add_column :action_officers, :phone, :string
    add_column :action_officers, :deputy_director_id, :integer
  end
end
