class CleanStatsData < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute(
      "UPDATE action_officers_pqs " +
      "SET updated_at = created_at " +
      "WHERE action_officer_id = 497;"
    )
  end
end
