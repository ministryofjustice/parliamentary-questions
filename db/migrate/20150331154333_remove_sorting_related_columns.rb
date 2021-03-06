class RemoveSortingRelatedColumns < ActiveRecord::Migration[5.0]
  def up
    change_table :pqs, bulk: true do |t|
      t.remove :date_for_answer_has_passed, :days_from_date_for_answer
    end
    add_index(:pqs, :date_for_answer)
    execute "CREATE INDEX days_from_date_for_answer ON pqs (DATE_PART('day', date_for_answer::timestamp))"
    add_index(:pqs, :state_weight)
    add_index(:pqs, :updated_at)
    add_index(:pqs, :internal_deadline)
    add_index(:pqs, :state)
    add_index(:pqs, :minister_id)
  end

  def down; end
end
