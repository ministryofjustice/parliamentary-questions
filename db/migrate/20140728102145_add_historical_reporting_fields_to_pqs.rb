class AddHistoricalReportingFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :at_acceptance_directorate_id, :integer
    add_column :pqs, :at_acceptance_division_id, :integer
  end
end
