class RenamePreviewUrlinPq < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.rename :answer_preview_url, :preview_url
    end
  end
end
