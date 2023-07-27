module Deployment
  def info
    { version_number:, build_date:, commit_id:, build_tag: }
  end

  def version_number
    ENV["APPVERSION"]
  end

  def build_date
    ENV["APP_BUILD_DATE"] || "unknown"
  end

  def commit_id
    ENV["APP_GIT_COMMIT"] || "unknown"
  end

  def build_tag
    ENV["APP_BUILD_TAG"] || "unknown"
  end

  extend self # rubocop:disable Style/ModuleFunction
end
