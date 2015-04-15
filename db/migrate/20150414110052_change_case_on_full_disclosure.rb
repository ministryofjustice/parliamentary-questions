class ChangeCaseOnFullDisclosure < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute "UPDATE pqs SET final_response_info_released = 'Full disclosure' where final_response_info_released = 'Full Disclosure'"
  end

  def down
  end
end
