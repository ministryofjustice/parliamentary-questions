class RemovePodQuery < ActiveRecord::Migration[7.1]
  def up
    change_table :pqs, bulk: true do |t|
      t.remove :pod_query_flag
      t.remove :pod_query
    end
  end

  def down
    change_table :pqs, bulk: true do |t|
      t.boolean :pod_query_flag
      t.datetime :pod_query, precision: nil
    end
  end
end
