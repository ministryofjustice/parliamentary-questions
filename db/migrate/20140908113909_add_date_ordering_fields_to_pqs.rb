class AddDateOrderingFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :days_from_date_for_answer, :integer
    add_column :pqs, :date_for_answer_has_passed, :boolean
  end
end
