class ChangeUniqueConstraintsForAo < ActiveRecord::Migration
  def change
    remove_index :action_officers, :email
    add_index :action_officers, [:email, :deputy_director_id], unique: true
  end
end
