class ImportServiceWithDatabaseLock

  def initialize(importService = ImportService.new)
    @importService = importService
    @progress_unallocated = Progress.unallocated
  end


  def questions(args = { dateFrom: Date.today} )
    # Warning: This is a naive implementation of a lock using the database, to prevent that a human
    # or a cron job with enough space between runs (for example 5 or 10 minutes)
    # could run the method multiple times.
    # It could happen that this method run concurrently if the rate of the calls is high, because
    # we are not using row or table locking in the database to do a 'compare-and-set' logic

    questions_imported = 0
    errors_count = 0

    runner = Random.rand(1000000000)
    ImportLog.create(log_type: 'START', msg: "#{runner}: start running the import")

    @importService.questions_with_callback(args) { |result|
      if !result[:error].nil?
        errors_count += 1
        ImportLog.create(log_type: 'ERROR', msg: "#{runner}: #{result[:error]} ::: #{result[:question]}")
      else
        questions_imported += 1
        ImportLog.create(log_type: 'SUCCESS', msg: "#{runner}: #{result[:error]} ::: #{result[:question]}")
      end
    }
    ImportLog.create(log_type: 'FINISH', msg: "#{runner}: Questions imported #{questions_imported}, Errors  #{errors_count}")

  end


end