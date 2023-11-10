class AddIndexToPqsUin < ActiveRecord::Migration[6.1]
  def change
    add_index :pqs, :uin, name: "index_pqs_on_uin", unique: true
  end
end
