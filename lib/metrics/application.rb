module Metrics
  class Application < Component
    attr_reader :version, :build_date, :build_tag, :git_sha

    def initialize
      @info = Deployment.info
    end

    def collect!
      @version    = @info[:version_number]
      @build_date = @info[:build_date]
      @build_tag  = @info[:build_tag]
      @git_sha    = @info[:commit_id]
    end
  end
end