class MailWorker
  MAX_FAIL_COUNT = Settings.mail_worker.max_fail_count
  PID_FILEPATH   = Settings.mail_worker.pid_filepath

  def initialize
    @service  = MailService
    @queue    = []
    @pid_file = PidFile.new(PID_FILEPATH)
  end

  def run!
    starting_worker do
      emails = @service.mail_to_send

      queue_mail(emails)
      process_queue
    end
  end

  private

  def starting_worker
    pid = Process.pid.to_s

    if @pid_file.present?
      raise ExistingMailWorkerProcess
    else
      @pid_file.pid = pid
    end

    yield

  ensure
    @pid_file.delete(pid)
  end

  def queue_mail(emails)
    emails.each do |email|
      @queue << email
      @service.record_attempt(email)
    end
  end

  def process_queue
    until @queue.empty? do
      begin
        email = @queue.shift
        process_mail(email)
      rescue 
        @service.record_fail(email)
      end
    end
  end

  def process_mail(email)
    if email.num_send_attempts > MAX_FAIL_COUNT
      @service.record_abandon(email)
    else
      @service.send_mail(email)
    end
  end

  class ExistingMailWorkerProcess < StandardError
    def initialize
      super("Existing MailWorker pid file found at: #{PID_FILEPATH}")
    end
  end
end