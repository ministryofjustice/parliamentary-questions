class CreateTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :tokens do |t|
      t.string :path
      t.string :token_digest
      t.datetime :expire
      t.string :entity

      t.timestamps
    end
  end
end
