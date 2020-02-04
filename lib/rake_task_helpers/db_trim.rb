module RakeTaskHelpers
  class DBTrim
    MY_SQLS = ['DELETE FROM pqs WHERE id NOT IN (SELECT id FROM pqs ORDER BY created_at DESC LIMIT 50);']
    def run!
      MY_SQLS.map do |sql|
        ActiveRecord::Base.connection.execute sql
      end
    end
  end
end
