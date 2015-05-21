class MetricsDashboardController < ApplicationController
  def index
    @dashboard = MetricsDashboard.new
    @dashboard.update

    respond_to do |format|
      format.html {
        authenticate_user!
      }

      format.json {
        if request.headers["Authorization"] == token
          render :json => Presenters::DashboardGecko.json_report(@dashboard.gecko)
        else
          render :file => "public/401.html", :status => :unauthorized
        end
      }
    end
  end

  private

  def token
    ActionController::HttpAuthentication::Basic
      .encode_credentials(Rails.application.config.gecko_auth_username, "X")
  end
end
