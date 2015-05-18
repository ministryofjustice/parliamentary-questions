class MetricsDashboardController < ApplicationController
  def index
    @metrics = MetricsDashboard.new
    @metrics.gather_metrics
  end
end
