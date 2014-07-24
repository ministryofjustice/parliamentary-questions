namespace :db do

  desc 'Imports data from a specified file and performs sql form a separate file. Data (*.txt) files MUST BE tilde (~) delimited'
  task :import_transform, [:datafile] => :environment do |t, args|
    args.with_defaults(datafile: 'localhost:somewhere')
    datafile =  args[:datafile]
    puts "Loading file: #{datafile}"


      connection = ActiveRecord::Base.connection

      # - IMPORTANT: SEED DATA ONLY
      # - Data (*.txt) files MUST BE tilde (~) delimited

    #  sql = File.open(sqlfile, "r:UTF-8", &:read)
    sql = File.read("db/import/PQ_ETL_ISO.sql")

      statements = sql.split(/;$/)

      statements.pop  # the last empty statement

      ActiveRecord::Base.transaction do
        statements.each do |statement|
          statement.sub! '/PQ Metadata fields.txt', datafile unless datafile == 'localhost:somewhere'
          puts 'Running: ' + statement
          connection.execute(statement)
          puts ' '
        end
      end

    puts 'Done'

  end
end