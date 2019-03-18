class AddAdditionalPqFieldsForImport < ActiveRecord::Migration[5.0]
  def change
    change_table :pqs, bulk: true do |t|
      t.string :member_name
      t.string :member_constituency
      t.string :house_name
      t.date :date_for_answer
      t.boolean :registered_interest
      t.rename :date_raised, :tabled_date
    end
  end
end
