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
    @import_service = ImportServiceWithDatabaseLock.new
  end

  def perform
    Rails.logger.info { "Import: starting scheduled import" }
    @import_service.questions(dateFrom: Date.yesterday)
    Rails.logger.info { "Import: completed scheduled import" }
  
  end

end
