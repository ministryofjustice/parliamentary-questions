class AddCountersToPqAo < ActiveRecord::Migration
  def change
    add_column :action_officers_pqs, :reminder_accept, :integer, :default => 0
    add_column :action_officers_pqs, :reminder_draft, :integer, :default => 0
  end
end
