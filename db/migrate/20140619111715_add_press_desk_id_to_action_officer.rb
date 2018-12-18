class AddPressDeskIdToActionOfficer < ActiveRecord::Migration[5.0]
  def change
    add_column :action_officers, :press_desk_id, :integer
  end
end
