class AddPodFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :pod_waiting, :datetime
    add_column :pqs, :pod_query, :datetime
    add_column :pqs, :pod_clearance, :datetime
  end
end
