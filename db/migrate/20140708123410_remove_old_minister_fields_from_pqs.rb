class RemoveOldMinisterFieldsFromPqs < ActiveRecord::Migration
  def change
   remove_column :pqs, :sent_to_answering_minister, :datetime
   remove_column :pqs, :ministerial_waiting, :datetime
   remove_column :pqs, :ministerial_query, :datetime
   remove_column :pqs, :ministerial_clearance, :datetime
   remove_column :pqs, :sent_back_to_action_officer, :datetime
   remove_column :pqs, :returned_by_action_officer, :datetime
   remove_column :pqs, :resubmitted_to_minister, :datetime
   remove_column :pqs, :sign_off_from_minister, :datetime
  end
end
