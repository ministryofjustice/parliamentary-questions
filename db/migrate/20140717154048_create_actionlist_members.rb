class CreateActionlistMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :actionlist_members, bulk: true do |t|
      t.string :name
      t.string :email
      t.boolean :deleted
      t.timestamps
    end
  end
end
