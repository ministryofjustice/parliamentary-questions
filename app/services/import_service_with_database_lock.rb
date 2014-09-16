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

    questions_by_state = {  'new' => 0, 'changed' => 0, 'unchanged' => 0 }

    @importService.questions_with_callback(args) { |result|
      msg="#{runner}: #{result[:error]} ::: #{result[:question]}"

      if result[:error].empty?
        $statsd.increment("#{StatsHelper::IMPORT}.number_questions_imported.#{result[:status]}")

        $statsd.increment("#{StatsHelper::IMPORT}.number_questions_imported.success")
        questions_by_state[result[:status]] += 1
        questions_imported += 1
        text = 'SUCCESS'
      else
        $statsd.increment("#{StatsHelper::IMPORT}.number_questions_imported.error")
        errors_count += 1
        text = 'ERROR'
      end
      create_import_log(text, msg)
    }

    delete_old_logs

    elapsed_seconds = Time.now - t_start

    breakdown = "[new=#{questions_by_state['new']},changed=#{questions_by_state['changed']}]"
    msg="#{runner}: [#{elapsed_seconds} seconds] Questions imported #{questions_imported} #{breakdown}, Errors  #{errors_count}"
    Rails.logger.info { "Importing  #{msg}" }
    create_import_log('FINISH', msg)

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
    Rails.logger.info { "Import: unable to obtain lock - continuing anyway" }
    # return true
    return false
  end


  def delete_old_logs
    ImportLog.where('created_at < ?', DateTime.now - 4.days).delete_all
  end

end
