class AddPodFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.datetime :pod_waiting
      t.datetime :pod_query
      t.datetime :pod_clearance
    end
  end
end
