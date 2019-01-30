class MergeAcceptRejectColumnsToResponse < ActiveRecord::Migration[5.0]
  def up
    change_table :action_officers_pqs, bulk: true do |t|
      t.string :response, default: 'awaiting'
    end
    execute("UPDATE action_officers_pqs SET response='rejected' WHERE reject=true")
    execute("UPDATE action_officers_pqs SET response='accepted' WHERE accept=true")
    change_table :action_officers_pqs, bulk: true do |t|
      t.remove :accept, :reject
    end
  end

  def down
    change_table :action_officers_pqs, bulk: true do |t|
      t.boolean :accept
      t.boolean :reject
    end
    execute("UPDATE action_officers_pqs SET accept=true WHERE response='accepted'")
    execute("UPDATE action_officers_pqs SET reject=true WHERE response='rejected'")
    change_table :action_officers_pqs, bulk: true do |t|
      t.remove :response
    end
  end
end
