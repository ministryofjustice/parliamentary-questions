require "#{Rails.root}/redeploy/pq_database_fixer.rb"

class FixDbStates < ActiveRecord::Migration
  def up
    Redeploy::PqDatabaseFixer.new.run
  end


  def down

  end
end
