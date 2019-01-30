class RemoveOldMinisterFieldsFromPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.datetime :sent_to_answering_minister
      t.datetime :ministerial_waiting
      t.datetime :ministerial_query
      t.datetime :ministerial_clearance
      t.datetime :sent_back_to_action_officer
      t.datetime :returned_by_action_officer
      t.datetime :resubmitted_to_minister
      t.datetime :sign_off_from_minister
    end
  end
end
