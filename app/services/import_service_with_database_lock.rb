class ImportServiceWithDatabaseLock

  def initialize(importService = ImportService.new, time_threshold = 60.minutes)
    @time_threshold = time_threshold
    @importService = importService
    @progress_unallocated = Progress.unassigned
  end


  def questions_no_lock(args = { dateFrom: Date.today} )
    questions_imported = 0
    errors_count = 0
    runner = Random.rand(1000000000)

    t_start = Time.now

    create_import_log('START',"#{runner}: start running the import, #{t_start}")

    @importService.questions_with_callback(args) { |result|
      if !result[:error].nil?
        errors_count += 1
        create_import_log('ERROR', "#{runner}: #{result[:error]} ::: #{result[:question]}")
      else
        questions_imported += 1
        create_import_log('SUCCESS', "#{runner}: #{result[:error]} ::: #{result[:question]}")
      end
    }

    delete_old_logs

    elapsed_seconds = Time.now - t_start

    create_import_log('FINISH', "#{runner}: [#{elapsed_seconds} seconds] Questions imported #{questions_imported}, Errors  #{errors_count}")

    {msg: msg, log_type: 'FINISH'}

  end

  def create_import_log(text, msg)
    ImportLog.create(log_type: text, msg: msg)
  end


  def questions(args = { dateFrom: Date.today} )
    # Warning: This is a naive implementation of a lock using the database, to prevent that a human
    # or a cron job with enough space between runs (for example 5 or 10 minutes)
    # could run the method multiple times.
    # It could happen that this method run concurrently if the rate of the calls is high, because
    # we are not using row or table locking in the database to do a 'compare-and-set' logic

    if !naive_lock_acquire
      return  {msg: 'other process is running or not enough time since the last process run', log_type: 'SKIP_RUN'}
    end

    questions_no_lock(args)
  end


  # just a delegate
  def questions_by_uin(uin)
    @importService.questions_by_uin(uin)
  end

  protected

  # Naive lock implementation (non atomic compare-and-set)
  # true if the lock could be acquired
  def naive_lock_acquire
    lastLog = ImportLog.order("created_at").last
    if lastLog.nil?
      return true
    end
    offset = DateTime.now - @time_threshold

    if offset > lastLog.created_at
      return  true
    end

    # # There is a problem with the lock logic - hacking it in here temporarily
    # Rails.logger.info { "Import: unable to obtain lock - continuing anyway" }
    # return true
    return false
  end


  def delete_old_logs
    ImportLog.where('created_at < ?', DateTime.now - 4.days).delete_all
  end

end
