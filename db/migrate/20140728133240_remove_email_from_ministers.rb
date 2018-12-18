class RemoveEmailFromMinisters < ActiveRecord::Migration[5.0]
  def change
    remove_column :ministers, :email, :string
  end
end
