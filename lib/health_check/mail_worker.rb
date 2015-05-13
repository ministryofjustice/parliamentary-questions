module HealthCheck
  class MailWorker < Component
    PID_FILE = Settings.mail_worker.pid_filepath
    TIMEOUT  = Settings.mail_worker.timeout

    def available?
      if stale_pid_file? || stale_unsent_mails?
        log_error('Timeout', "mail queue process time > #{TIMEOUT} seconds")
        false
      else
        true
      end

    rescue => e
      log_unknown_error(e)
      false
    end

    def accessible?
      failures = MailService.abandoned_mail

      unless failures.empty?
        log_error('Mail Service', "#{failures.count} email(s) abandoned")
        false
      else
        true
      end

    rescue => e
      log_unknown_error(e)
      false
    end

    private

    def stale_pid_file?
      File.exists?(PID_FILE) && File.ctime(PID_FILE) < (Time.now - TIMEOUT)
    end

    def stale_unsent_mails?
      MailService.new_mail.any? { |email| email.created_at < (Time.now - TIMEOUT) }
    end

    def log_error(type, msg)
      @errors << "MailWorker #{type} Error: #{msg}"
    end
  end
end
