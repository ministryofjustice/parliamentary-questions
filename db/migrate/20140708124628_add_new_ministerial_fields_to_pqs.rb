class AddNewMinisterialFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.datetime :sent_to_policy_minister
      t.boolean  :policy_minister_query
      t.datetime :policy_minister_to_action_officer
      t.datetime :policy_minister_returned_by_action_officer
      t.datetime :resubmitted_to_policy_minister
      t.datetime :cleared_by_policy_minister
      t.datetime :sent_to_answering_minister
      t.boolean  :answering_minister_query
      t.datetime :answering_minister_to_action_officer
      t.datetime :answering_minister_returned_by_action_officer
      t.datetime :resubmitted_to_answering_minister
      t.datetime :cleared_by_answering_minister
    end
  end
end
