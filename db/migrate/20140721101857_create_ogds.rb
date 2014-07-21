class CreateOgds < ActiveRecord::Migration
  def change
    create_table :ogds do |t|
      t.string :name
      t.string :acronym
      t.boolean :deleted

      t.timestamps
    end
  end
end
