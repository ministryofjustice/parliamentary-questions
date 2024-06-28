class AddArchivePrefix < ActiveRecord::Migration[7.1]
  def change
    create_table :archives do |t|
      t.string :prefix, index: { unique: true }

      t.timestamps
    end

    %w[hl # * $ ^ ~ £ a b].each do |prefix|
      Archive.create(prefix:)
    end
  end
end
