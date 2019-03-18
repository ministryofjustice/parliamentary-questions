class AddHistoricalReportingFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.integer :at_acceptance_directorate_id
      t.integer :at_acceptance_division_id
    end
  end
end
