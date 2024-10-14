class DeleteWatchlistMembers < ActiveRecord::Migration[7.1]
  def up
    drop_table :watchlist_members
  end

  def down
    create_table :watchlist_members do |t|
      t.string :name
      t.string :email
      t.boolean :deleted

      t.timestamps
    end
  end
end
