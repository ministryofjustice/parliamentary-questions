class CreateEarlyBirdOrganisers < ActiveRecord::Migration[6.1]
  def change
    create_table :early_bird_organisers do |t|
      t.date :date_from
      t.date :date_to

      t.timestamps
    end
  end
end
