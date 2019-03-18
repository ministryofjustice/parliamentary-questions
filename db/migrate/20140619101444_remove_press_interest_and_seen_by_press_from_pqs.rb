class RemovePressInterestAndSeenByPressFromPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.remove :press_interest, :seen_by_press
    end
  end
end
