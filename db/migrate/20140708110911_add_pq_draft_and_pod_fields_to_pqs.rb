class AddPqDraftAndPodFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.boolean  :i_will_write
      t.boolean  :pq_correction_received
      t.datetime :correction_circulated_to_action_officer
      t.boolean  :pod_query_flag
    end
  end
end
