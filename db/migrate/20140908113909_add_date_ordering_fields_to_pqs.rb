class AddDateOrderingFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.integer :days_from_date_for_answer
      t.boolean :date_for_answer_has_passed
    end
  end
end
