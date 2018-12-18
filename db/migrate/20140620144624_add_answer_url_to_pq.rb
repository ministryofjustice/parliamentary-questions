class AddAnswerUrlToPq < ActiveRecord::Migration[5.0]
  def change
    add_column :pqs, :answer_preview_url, :string
  end
end
