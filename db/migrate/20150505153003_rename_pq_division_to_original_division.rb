class RenamePqDivisionToOriginalDivision < ActiveRecord::Migration[5.0]
  def change
    rename_column :pqs, :division_id, :original_division_id
  end
end
