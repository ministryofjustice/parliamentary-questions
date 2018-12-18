class AddUniqueToAo < ActiveRecord::Migration[5.0]
  def change
    add_index :action_officers, :email, unique: true
  end
end
