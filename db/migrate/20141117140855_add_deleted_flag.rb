class AddDeletedFlag < ActiveRecord::Migration[5.0]
  def change
    add_column :trim_links, :deleted, :boolean
  end
end
