module RakeTaskHelpers
  class DBSanitizer

    SANITIZABLE_TABLES =
    [
      { 'table' => 'action_officers',    'abbreviation'    => 'ao',  'column' => 'email'},
      { 'table' => 'actionlist_members', 'abbreviation'    => 'alm', 'column' => 'email'},
      { 'table' => 'deputy_directors',   'abbreviation'    => 'dd',  'column' => 'email'},
      { 'table' => 'minister_contacts',  'abbreviation'    => 'mc',  'column' => 'email'},
      { 'table' => 'press_officers',     'abbreviation'    => 'po',  'column' => 'email'},
      { 'table' => 'users',              'abbreviation'    => 'u',   'column' => 'email'},
      { 'table' => 'watchlist_members',  'abbreviation'    => 'wlm', 'column' => 'email'},
      { 'table' => 'early_bird_members', 'abbreviation'    => 'ebm', 'column' => 'email'},
      { 'table' => 'action_officers',    'abbreviation'    => 'gm',  'column' => 'group_email'}
    ]

    def run!
      SANITIZABLE_TABLES.map do |row|
        sanitize_email(row["table"], row["abbreviation"], row["column"])
      end
    end

    private

    def sanitize_email(table, abbreviation, column)
      sql = "update #{table} set #{column} ='pqsupport+#{abbreviation}' || id || '@digital.justice.gov.uk';"
      ActiveRecord::Base.connection.execute sql
    end
  end
end
