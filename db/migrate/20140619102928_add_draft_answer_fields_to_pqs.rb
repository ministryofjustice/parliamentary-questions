class AddDraftAnswerFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.datetime :draft_answer_received
      t.datetime :i_will_write_estimate
      t.datetime :holding_reply
    end
  end
end
