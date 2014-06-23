class ChangeTypeOfStringToText < ActiveRecord::Migration
  def up
    change_column :pqs, :question, :text
    change_column :action_officers_pqs, :reason, :text
  end
  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :pqs, :question, :string
    change_column :action_officers_pqs, :reason, :string
  end
end
