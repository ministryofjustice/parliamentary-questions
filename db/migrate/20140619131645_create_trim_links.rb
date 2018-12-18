class CreateTrimLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :trim_links do |t|
      t.string :filename
      t.integer :size
      t.binary :data
      t.integer :pq_id
      t.timestamps
    end
  end
end
