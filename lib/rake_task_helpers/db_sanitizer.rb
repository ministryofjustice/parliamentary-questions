module RakeTaskHelpers
  class DBSanitizer
    SANITIZABLE_TABLES = 
    {
      'action_officers'    => 'ao',
      'actionlist_members' => 'alm',
      'deputy_directors'   => 'dd',
      'minister_contacts'  => 'mc',
      'press_officers'     => 'po',
      'users'              => 'u',
      'watchlist_members'  => 'wlm'
    }

    def run!
      SANITIZABLE_TABLES.each do |table, abbreviation|
        sanitize_email(table, abbreviation)
      end 
    end

    private

    def sanitize_email(table, abbreviation)
      sql = "update #{table} set email='pqsupport+#{abbreviation}' || id || '@digital.justice.gov.uk';"
      ActiveRecord::Base.connection.execute sql
    end
  end
end