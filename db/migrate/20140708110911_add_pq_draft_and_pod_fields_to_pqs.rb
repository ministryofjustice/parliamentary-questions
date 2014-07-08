class AddPqDraftAndPodFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :i_will_write, :boolean
    add_column :pqs, :pq_correction_received, :boolean
    add_column :pqs, :correction_circulated_to_action_officer, :datetime
    add_column :pqs, :pod_query_flag, :boolean
  end
end
