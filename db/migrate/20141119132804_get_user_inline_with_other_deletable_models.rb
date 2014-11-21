class GetUserInlineWithOtherDeletableModels < ActiveRecord::Migration
  def up
    execute('UPDATE users SET is_active = NOT is_active')
    rename_column :users, :is_active, :deleted
  end

  def down
    rename_column :users, :deleted, :is_active
    execute('UPDATE users SET is_active = NOT is_active')
  end
end
