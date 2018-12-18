class AddMemberIdToMinisters < ActiveRecord::Migration[5.0]
  def change
    add_column :ministers, :member_id, :integer
  end
end
