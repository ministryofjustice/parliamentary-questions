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
        LogStuff.info { "Import: completed scheduled import" }
        
        MailService::Import.notify_success(report)
        PqaImportRun.record_success(start_time, report)

      rescue => err
        PqaImportRun.record_failure(start_time, "#{err.class}: #{err.message}")
        case err
        when HTTPClient::FailureResponse, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError
          LogStuff.error { err.message }
          MailService::Import.notify_fail(err.message)
        else
          raise err
        end
      end
    end
  end
end
