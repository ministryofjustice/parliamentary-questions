class ImportWorker
  def initialize
    @import = PQA::Import.new
  end

  def perform
    date_from = PQAImportRun.last_import_time_utc
    date_to = 5.minutes.from_now
    start_time = Time.zone.now
    LogStuff.tag(:import) do
      LogStuff.info { "Import: starting scheduled import from #{date_from} to #{date_to}" }
      report = @import.run(date_from, date_to)
      LogStuff.info { "Import: completed scheduled import" }

      NotifyImportMailer.notify_success(report).deliver_later
      PQAImportRun.record_success(start_time, report)
    rescue StandardError => e
      PQAImportRun.record_failure(start_time, "#{e.class}: #{e.message}")
      case e
      when HTTPClient::FailureResponse, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError
        LogStuff.error { e.message }
        NotifyImportMailer.notify_fail(e.message).deliver_later
      else
        raise e
      end
    end
  end
end
