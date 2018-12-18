class CreateEarlyBirdMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :early_bird_members do |t|
      t.string :name
      t.string :email
      t.boolean :deleted
      
      t.timestamps
    end
  end
end
