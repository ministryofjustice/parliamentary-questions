class AddMinisterialFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :sent_to_answering_minister, :datetime
    add_column :pqs, :ministerial_waiting, :datetime
    add_column :pqs, :ministerial_query, :datetime
    add_column :pqs, :ministerial_clearance, :datetime
    add_column :pqs, :sent_back_to_action_officer, :datetime
    add_column :pqs, :returned_by_action_officer, :datetime
    add_column :pqs, :resubmitted_to_minister, :datetime
    add_column :pqs, :sign_off_from_minister, :datetime
  end
end
