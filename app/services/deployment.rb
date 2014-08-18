module Deployment
  def info
    { version_number: version_number, build_time: build_time, commit_id: commit_id }
  end

  def version_number
    ENV['APPVERSION']
  end

  def build_time
    ENV['APP_BUILD_TIME'] || 'unknown'
  end

  def commit_id
    ENV['APP_COMMIT_ID'] || 'unknown'
  end

  extend self
end
