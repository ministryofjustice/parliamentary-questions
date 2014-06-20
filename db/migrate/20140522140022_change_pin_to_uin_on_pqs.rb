class ChangePinToUinOnPqs < ActiveRecord::Migration
  def change
 	  remove_column :pqs, :pin, :string
	  add_column :pqs, :uin, :string
  end
end
