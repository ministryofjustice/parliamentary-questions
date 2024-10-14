class RemoveFinanceInterestColumns < ActiveRecord::Migration[7.1]
  def up
    change_table :pqs, bulk: true do |t|
      t.remove :seen_by_finance
      t.remove :finance_interest
    end
  end

  def down
    change_table :pqs, bulk: true do |t|
      t.boolean :seen_by_finance, default: false
      t.boolean :finance_interest
    end
  end
end
