class AddImportLog < ActiveRecord::Migration[5.0]
  def change
    create_table :import_logs do |t|
      t.string :log_type
      t.text :msg
      t.timestamps
    end
  end
end
