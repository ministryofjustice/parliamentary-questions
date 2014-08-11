namespace :db do

  desc 'Imports data from a specified file and performs sql form a separate file. Data (*.txt) files MUST BE tilde (~) delimited'
  task :import_transform, [:datafile] => :environment do |t, args|
    args.with_defaults(datafile: 'localhost:somewhere')
    datafile =  args[:datafile]
    puts "Loading file: #{datafile}"

    connection = ActiveRecord::Base.connection
    rc = connection.raw_connection
    puts 'Pre-populate Progresses'
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE progresses RESTART IDENTITY;")
    Progress.create([
                        {name: Progress.UNASSIGNED},
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

    # - IMPORTANT: SEED DATA ONLY
    # - Data (*.txt) files MUST BE tilde (~) delimited

    #  sql = File.open(sqlfile, "r:UTF-8", &:read)
    sql = File.read("db/import/PQ_ETL_ISO.sql")

    statements = sql.split(/;$/)

    statements.pop  # the last empty statement

    ActiveRecord::Base.transaction do
      statements.each do |statement|
        puts "Running: #{statement}\n"
        rc.exec(statement)

        if statement =~ /STDIN/
          file = File.open(datafile)
          while !file.eof?
            rc.put_copy_data(file.readline)
          end
          rc.put_copy_end
        end
        puts ' '
      end
    end
    connection = ActiveRecord::Base.connection

    puts 'Done'

  end
end
