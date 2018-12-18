class CreateMinisters < ActiveRecord::Migration[5.0]
  def change
    create_table :ministers do |t|
      t.string :name
      t.string :title
      t.string :email
      t.boolean :deleted

      t.timestamps
    end
  end
end
