class RemoveMinisterCheckFields < ActiveRecord::Migration[7.1]
  def up
    change_table :pqs, bulk: true do |t|
      t.remove :answering_minister_query
      t.remove :answering_minister_to_action_officer
      t.remove :answering_minister_returned_by_action_officer
      t.remove :resubmitted_to_answering_minister
      t.remove :policy_minister_query
      t.remove :policy_minister_to_action_officer
      t.remove :policy_minister_returned_by_action_officer
      t.remove :resubmitted_to_policy_minister
    end
  end

  def down
    change_table :pqs, bulk: true do |t|
      t.boolean :answering_minister_query
      t.datetime :answering_minister_to_action_officer
      t.datetime :answering_minister_returned_by_action_officer
      t.datetime :resubmitted_to_answering_minister
      t.boolean :policy_minister_query
      t.datetime :policy_minister_to_action_officer
      t.datetime :policy_minister_returned_by_action_officer
      t.datetime :resubmitted_to_policy_minister
    end
  end
end
