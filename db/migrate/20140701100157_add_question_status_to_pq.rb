class AddQuestionStatusToPq < ActiveRecord::Migration
  def change
    add_column :pqs, :question_status, :string
  end
end
