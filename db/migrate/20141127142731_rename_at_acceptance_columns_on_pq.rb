class RenameAtAcceptanceColumnsOnPq < ActiveRecord::Migration
  def change
    rename_column :pqs, :at_acceptance_directorate_id, :directorate_id
    rename_column :pqs, :at_acceptance_division_id, :division_id
  end
end
