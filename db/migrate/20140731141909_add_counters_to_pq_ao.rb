class AddCountersToPqAo < ActiveRecord::Migration[5.0]
  def change
    change_table :action_officers_pqs, bulk: true do |t|
      t.integer :reminder_accept, default: 0
      t.integer :reminder_draft,  default: 0
    end
  end
end
