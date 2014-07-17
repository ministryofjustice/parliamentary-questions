class CreateActionlistMembers < ActiveRecord::Migration
  def change
    create_table :actionlist_members do |t|
      t.string :name
      t.string :email
      t.boolean :deleted

      t.timestamps
    end
  end
end
