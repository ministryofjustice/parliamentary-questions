class AddAnswerTabFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :answer_submitted, :datetime
    add_column :pqs, :library_deposit, :boolean
    add_column :pqs, :pq_withdrawn, :datetime
    add_column :pqs, :holding_reply_flag, :boolean
    add_column :pqs, :final_response_info_released, :string
  end
end
