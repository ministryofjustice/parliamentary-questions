class MergeAcceptRejectColumnsToResponse < ActiveRecord::Migration
  def up
    add_column :action_officers_pqs, :response, :string, default: 'awaiting'

    execute("UPDATE action_officers_pqs SET response='accepted' WHERE accept=true")
    execute("UPDATE action_officers_pqs SET response='rejected' WHERE reject=true")

    remove_column :action_officers_pqs, :accept
    remove_column :action_officers_pqs, :reject
  end

  def down
    add_column :action_officers_pqs, :accept, :boolean
    add_column :action_officers_pqs, :reject, :boolean

    execute("UPDATE action_officers_pqs SET accept=true WHERE response='accepted'")
    execute("UPDATE action_officers_pqs SET reject=true WHERE response='rejected'")

    remove_column :action_officers_pqs, :response
  end
end
