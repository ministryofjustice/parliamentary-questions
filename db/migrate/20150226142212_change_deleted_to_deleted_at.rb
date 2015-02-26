class ChangeDeletedToDeletedAt < ActiveRecord::Migration
  def up
    [
      'action_officers',
      'actionlist_members',
      'deputy_directors',
      'directorates',
      'divisions',
      'minister_contacts',
      'ministers',
      'ogds',
      'press_desks',
      'press_officers',
      'trim_links',
      'users',
      'watchlist_members'
    ].each do |table|

      ActiveRecord::Base.execute(sql)

      add_column(table, :deleted_at, :datetime)
      add_index(table, :deleted_at)


    end
  end

  def down
     raise ActiveRecord::IrreversibleMigrationError
  end
end
