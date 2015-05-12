class MailWorker
  MAX_FAIL_COUNT = Settings.mail_worker.max_fail_count
  PID_FILEPATH   = Settings.mail_worker.pid_filepath

  def initialize
    @q = MailService::Queue.new
  end

  def run!
    starting_worker do
      emails = MailService.mail_to_send

      queue_mail(emails)
      process_queue
    end
  end

  private

  def starting_worker
    pid = Process.pid.to_s

    if File.exists?(PID_FILEPATH)
      raise ExistingMailWorkerProcess
    else
      File.open(PID_FILEPATH, 'w') { |f| f.write(pid) }
    end

    yield

  ensure
    if File.exists?(PID_FILEPATH) && File.read(PID_FILEPATH) == pid
      File.delete(PID_FILEPATH) 
    end
  end

  def queue_mail(emails)
    emails.each do |email|
      @q.enqueue(email)
      MailService.record_attempt(email)
    end
  end

  def process_queue
    until @q.empty? do
      begin
        email = @q.dequeue
        process_mail(email)
      rescue 
        MailService.record_fail(email)
      end
    end
  end

  def process_mail(email)
    if email.num_send_attempts > MAX_FAIL_COUNT
      MailService.record_abandon(email)
    else
      MailService.send_mail(email)
    end
  end

  class ExistingMailWorkerProcess < StandardError
    def initialize
      super("Existing MailWorker pid file found at: #{PID_FILEPATH}")
    end
  end
end