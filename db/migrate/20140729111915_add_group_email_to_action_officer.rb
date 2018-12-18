class AddGroupEmailToActionOfficer < ActiveRecord::Migration[5.0]
  def change
    add_column :action_officers, :group_email, :string
  end
end
