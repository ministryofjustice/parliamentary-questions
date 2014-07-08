class AddRrDateQuidanceReceivedToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :round_robin_guidance_received, :datetime
  end
end
