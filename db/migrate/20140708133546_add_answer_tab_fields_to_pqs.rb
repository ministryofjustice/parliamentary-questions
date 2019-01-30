class AddAnswerTabFieldsToPqs < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.datetime :answer_submitted
      t.boolean  :library_deposit
      t.datetime :pq_withdrawn
      t.boolean  :holding_reply_flag
      t.string   :final_response_info_released
    end
  end
end
