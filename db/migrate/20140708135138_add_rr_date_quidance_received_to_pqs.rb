class AddRrDateQuidanceReceivedToPqs < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :round_robin_guidance_received, :datetime
  end
end
