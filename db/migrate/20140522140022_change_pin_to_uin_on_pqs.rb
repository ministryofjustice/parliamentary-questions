class ChangePinToUinOnPqs < ActiveRecord::Migration[5.0]
  def change
    remove_column :pqs, :pin, :string
    add_column :pqs, :uin, :string
  end
end
