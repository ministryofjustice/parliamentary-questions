class AddInternalDeadlineToPq < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :internal_deadline, :datetime
  end
end
