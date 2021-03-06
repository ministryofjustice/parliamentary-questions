class CreateMinisterContact < ActiveRecord::Migration[5.0]
  def change
    create_table :minister_contacts do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.integer :minister_id
      t.boolean :deleted
    end
  end
end
