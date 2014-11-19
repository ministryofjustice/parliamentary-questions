class SetDefaultForSeenByFinance < ActiveRecord::Migration
  def up
    change_column :pqs, :seen_by_finance, :boolean, default: false
    execute('UPDATE pqs SET seen_by_finance = false WHERE seen_by_finance IS NULL')
  end

  def down
    change_column :pqs, :seen_by_finance, :boolean, default: nil
  end
end
