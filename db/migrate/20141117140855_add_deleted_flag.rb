class AddDeletedFlag < ActiveRecord::Migration
  def change
    add_column :trim_links, :deleted, :boolean
  end
end
