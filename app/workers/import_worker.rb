class ImportWorker
  def initialize
    @import = PQA::Import.new
  end

  def perform
    LogStuff.tag(:import) do
      LogStuff.info { "Import: starting scheduled import" }
      PaperTrail.whodunnit = 'SideKiq'
      yesterday = Date.today - 1.day
      tomorrow  = Date.today + 1.day
      @import.run(yesterday, tomorrow)
      LogStuff.info { "Import: completed scheduled import" }
    end
  end
end
