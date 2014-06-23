class RenamePreviewUrlinPq < ActiveRecord::Migration
  def change
    change_table :pqs do |t|
      t.rename :answer_preview_url, :preview_url
    end
  end
end
