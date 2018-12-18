class AddQuestionTypeToPq < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :question_type, :string
  end
end
