class ImportWorker
  def initialize
    @import = PQA::Import.new
  end

  def perform
    LogStuff.tag(:import) do
      begin
        LogStuff.info { "Import: starting scheduled import" }
        PaperTrail.whodunnit = 'SideKiq'

        report = @import.run(Date.yesterday, Date.tomorrow)
        
        LogStuff.info { "Import: completed scheduled import" }

        ImportMailer.notify_success(report)
        binding.pry
      rescue HTTPClient::FailureResponse => err
          LogStuff.error { err.message }
          ImportMailer.notify_fail(err.message)
      rescue Net::ReadTimeout => err
          LogStuff.error { "PQ rest api request timed out" }
          ImportMailer.notify_fail(err.message)
      rescue Errno::ECONNREFUSED => err
          LogStuff.error { "PQ rest API refused HTTP connection" }
          ImportMailer.notify_fail(err.message)
      end
    end
  end
end
