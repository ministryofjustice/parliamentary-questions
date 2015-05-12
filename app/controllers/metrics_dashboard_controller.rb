class MetricsDashboardController < ApplicationController
  before_action :authenticate_user!, PQUserFilter


  def index
    @metrics = MetricsDashboard.new
    @metrics.gather_metrics
  end
end
