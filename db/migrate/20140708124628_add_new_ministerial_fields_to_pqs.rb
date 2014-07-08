class AddNewMinisterialFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :sent_to_policy_minister, :datetime
    add_column :pqs, :policy_minister_query, :boolean
    add_column :pqs, :policy_minister_to_action_officer, :datetime
    add_column :pqs, :policy_minister_returned_by_action_officer, :datetime
    add_column :pqs, :resubmitted_to_policy_minister, :datetime
    add_column :pqs, :cleared_by_policy_minister, :datetime
    add_column :pqs, :sent_to_answering_minister, :datetime
    add_column :pqs, :answering_minister_query, :boolean
    add_column :pqs, :answering_minister_to_action_officer, :datetime
    add_column :pqs, :answering_minister_returned_by_action_officer, :datetime
    add_column :pqs, :resubmitted_to_answering_minister, :datetime
    add_column :pqs, :cleared_by_answering_minister, :datetime
  end
end
