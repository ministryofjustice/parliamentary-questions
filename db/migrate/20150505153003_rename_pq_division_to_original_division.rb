class RenamePqDivisionToOriginalDivision < ActiveRecord::Migration
  def change
    rename_column :pqs, :division_id, :original_division_id
  end
end
