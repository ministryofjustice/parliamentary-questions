require "#{Rails.root}/redeploy/pq_database_fixer.rb"

class FixDbStates < ActiveRecord::Migration[5.0]
  def up
    Redeploy::PqDatabaseFixer.new.run
  end


  def down

  end
end
