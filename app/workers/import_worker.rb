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
  include Sidekiq::Worker


  def initialize
    @import_service = ImportServiceWithDatabaseLock.new
  end

  def perform
    @import_service.questions()
  end

end