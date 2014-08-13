namespace :db do

  desc 'Imports data from a specified file and performs sql form a separate file. Data (*.txt) files MUST BE tilde (~) delimited'
  task :import_transform, [:datafile, :debug_output] => :environment do |t, args|

    args.with_defaults(datafile: 'localhost:somewhere', debug_output: true)
    datafile =  args[:datafile]
    debug_output = args[:debug_output]

    # - IMPORTANT: SEED DATA ONLY
    puts 'Ensure all tables are truncated'
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE tokens RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE press_officers RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE action_officers RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE directorates RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE watchlist_members RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE progresses RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE ministers RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE divisions RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE deputy_directors RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE trim_links RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE minister_contacts RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE import_logs RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE actionlist_members RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE pqs RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE press_desks RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE action_officers_pqs RESTART IDENTITY;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE ogds RESTART IDENTITY;")

    puts 'Pre-populate Progresses'
    Progress.create([   {name: Progress.UNASSIGNED},
                        {name: Progress.NO_RESPONSE},
                        {name: Progress.ACCEPTED},
                        {name: Progress.REJECTED},
                        {name: Progress.DRAFT_PENDING},
                        {name: Progress.WITH_POD},
                        {name: Progress.POD_QUERY},
                        {name: Progress.POD_CLEARED},
                        {name: Progress.WITH_MINISTER},
                        {name: Progress.MINISTERIAL_QUERY},
                        {name: Progress.MINISTER_CLEARED},
                        {name: Progress.ANSWERED},
                        {name: Progress.TRANSFERRED_OUT}])

    connection = ActiveRecord::Base.connection
    rc = connection.raw_connection
    # - Data (*.txt) files MUST BE tilde (~) delimited
    puts "Loading file: #{datafile}" if debug_output
    #  sql = File.open(sqlfile, "r:UTF-8", &:read)
    sql = File.read("db/import/PQ_ETL_ISO.sql")

    statements = sql.split(/;$/)

    statements.pop  # the last empty statement
    puts "Executing #{statements.size} statements" unless debug_output==true
    ActiveRecord::Base.transaction do
        count=0
        statements.each do |statement|
        count+=1
        puts "Running: #{statement}\n" if debug_output==true
        puts "Running statement: #{count}" unless debug_output==true
        rc.exec(statement)

        if statement =~ /STDIN/
          file = File.open(datafile)
          while !file.eof?
            rc.put_copy_data(file.readline)
          end
          rc.put_copy_end
        end
        puts ' ' if debug_output==true
      end
    end
    connection = ActiveRecord::Base.connection

    puts 'Done'

  end
end
