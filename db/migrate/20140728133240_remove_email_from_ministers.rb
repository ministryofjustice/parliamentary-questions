class RemoveEmailFromMinisters < ActiveRecord::Migration
  def change
    remove_column :ministers, :email, :string
  end
end
