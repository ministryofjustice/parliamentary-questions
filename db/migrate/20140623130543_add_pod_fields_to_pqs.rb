class AddPodFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :pod_waiting, :datetime
    add_column :pqs, :pod_query, :datetime
    add_column :pqs, :pod_clearance, :datetime
  end
end
