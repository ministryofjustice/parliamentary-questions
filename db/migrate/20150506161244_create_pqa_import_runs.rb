class CreatePQAImportRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :pqa_import_runs do |t|
      t.datetime  :start_time
      t.datetime  :end_time
      t.string    :status
      t.integer   :num_created
      t.integer   :num_updated
      t.text      :error_messages

      t.timestamps
    end
  end
end
