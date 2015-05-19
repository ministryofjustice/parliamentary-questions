class MetricsDashboardController < ApplicationController
  def index
    @metrics = MetricsDashboard.new
    @metrics.gather_metrics
    respond_to do |format|
      format.html
      format.json {
        @obj = Presenters::DashboardGecko.list(@metrics.gecko)
        render :json => @obj.to_json
      }
    end
  end
end
