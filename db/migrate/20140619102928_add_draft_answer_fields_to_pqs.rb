class AddDraftAnswerFieldsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :draft_answer_received, :datetime
    add_column :pqs, :i_will_write_estimate, :datetime
    add_column :pqs, :holding_reply, :datetime
  end
end
