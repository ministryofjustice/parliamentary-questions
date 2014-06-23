class CreateTrimLinks < ActiveRecord::Migration
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
