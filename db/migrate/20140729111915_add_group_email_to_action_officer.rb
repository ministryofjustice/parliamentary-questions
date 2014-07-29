class AddGroupEmailToActionOfficer < ActiveRecord::Migration
  def change
    add_column :action_officers, :group_email, :string
  end
end
