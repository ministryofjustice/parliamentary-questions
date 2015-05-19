class MetricsDashboardController < ApplicationController
  def index
    @metrics = MetricsDashboard.new
    @metrics.gather_metrics
    respond_to do |format|
      format.html {
        authenticate_user!
      }
      format.json {
        token = ActionController::HttpAuthentication::Basic.encode_credentials(Rails.application.config.gecko_auth_username, "X")
        if request.headers["Authorization"] == token
          obj = Presenters::DashboardGecko.list(@metrics.gecko)
          render :json => obj.to_json
        else
          render :file => "public/401.html", :status => :unauthorized
        end
      }
    end
  end
end
