class AddMemberIdToMinisters < ActiveRecord::Migration
  def change
    add_column :ministers, :member_id, :integer
  end
end
