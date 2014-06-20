class AddAnswerUrlToPq < ActiveRecord::Migration
  def change
    add_column :pqs, :answer_preview_url, :string
  end
end
