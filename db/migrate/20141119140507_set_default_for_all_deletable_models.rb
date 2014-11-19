class SetDefaultForAllDeletableModels < ActiveRecord::Migration
  TABLES_WITH_DELETED = %w(action_officers
    actionlist_members
    deputy_directors
    directorates
    divisions
    minister_contacts
    ministers
    ogds
    press_desks
    press_officers
    trim_links
    users
    watchlist_members)

  def up
    TABLES_WITH_DELETED.each do |table|
      change_column table, :deleted, :boolean, default: false
      execute("UPDATE #{table} SET deleted = false WHERE deleted IS NULL")
    end
  end

  def down
    TABLES_WITH_DELETED.each do |table|
      change_column table, :deleted, :boolean, default: nil
    end
  end
end
