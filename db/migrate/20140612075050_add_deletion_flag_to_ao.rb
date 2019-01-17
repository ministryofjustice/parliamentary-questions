class AddDeletionFlagToAo < ActiveRecord::Migration[5.0]
  def change
    add_column :action_officers, :deleted, :boolean
  end
end
