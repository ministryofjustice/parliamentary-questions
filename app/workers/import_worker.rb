# Sideqik Worker, more info here http://sidekiq.org/
#
# To run the workers:
#   $ bundle exec sidekiq
#
# Dependencies:
#
#   You need a Redis server on -> localhost:6379
#   or you can setup the environment variable
#
#     $ export REDIS_URL=redis://my_redis_server:6379
#
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
