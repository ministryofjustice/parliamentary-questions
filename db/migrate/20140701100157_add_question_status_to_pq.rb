class AddQuestionStatusToPq < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :question_status, :string
  end
end
