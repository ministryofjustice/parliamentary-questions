class MetricsDashboard
  class AppInfo < Component
    attr_accessor :version, :build_date, :build_tag, :git_sha

    def initialize
      @info = Deployment.info
    end

    def gather_metrics
      @version    = @info[:version_number]
      @build_date = @info[:build_date]
      @build_tag  = @info[:build_tag]
      @git_sha    = @info[:commit_id]
    end
  end
end