class CleanStatsData < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute(
      "UPDATE action_officers_pqs " +
      "SET updated_at = created_at " +
      "WHERE action_officer_id = 497;"
    )
    
    ActiveRecord::Base.connection.execute(
      "UPDATE action_officers_pqs " +
      "SET created_at = pqs.created_at FROM pqs " +
      "WHERE action_officers_pqs.action_officer_id = 497 " +
      "AND action_officers_pqs.pq_id = pqs.id;"
    )
  end
end
