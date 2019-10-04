class ImportWorker
  def initialize
    @import = PQA::Import.new
  end

  def perform
    date_from = PqaImportRun.last_import_time_utc
    date_to = 5.minutes.from_now
    start_time = Time.now
    LogStuff.tag(:import) do
      begin
        LogStuff.info { "Import: starting scheduled import from #{date_from} to #{date_to}" }
        report = @import.run(date_from, date_to)
        LogStuff.info { 'Import: completed scheduled import' }

        MailService::Import.notify_success(report)
        PqaImportRun.record_success(start_time, report)
      rescue => e
        PqaImportRun.record_failure(start_time, "#{e.class}: #{e.message}")
        case e
        when HTTPClient::FailureResponse, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError
          LogStuff.error { e.message }
          MailService::Import.notify_fail(e.message)
        else
          raise e
        end
      end
    end
  end
end
