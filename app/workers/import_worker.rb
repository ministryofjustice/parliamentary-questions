class ImportWorker
  def initialize
    @import = PQA::Import.new
  end

  def perform
    LogStuff.tag(:import) do
      begin
        LogStuff.info { "Import: starting scheduled import" }
        report = @import.run(Date.yesterday, Date.tomorrow)
        LogStuff.info { "Import: completed scheduled import" }
        ImportMailer.notify_success(report).deliver

      rescue => err
        case err
        when HTTPClient::FailureResponse, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError
          LogStuff.error { err.message }
          ImportMailer.notify_fail(err.message).deliver
        else
          raise err
        end
      end
    end
  end
end
