class AddActiveToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_active, :boolean
  end
end
