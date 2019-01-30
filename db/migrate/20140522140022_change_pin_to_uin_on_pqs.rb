class ChangePinToUinOnPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.remove :pin
      t.string :uin
    end
  end
end
