require 'json'
class GeckoReportController < ApplicationController
  def index
    @gecko_report = GeckoReport.new
    # @dashboard.update

    respond_to do |format|
      format.html {
        authenticate_user!
      }

      format.json {
        if request.headers["Authorization"] == token
          render :json => @gecko_report.to_json
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
    puts ActionController::HttpAuthentication::Basic.encode_credentials(Rails.application.config.gecko_auth_username, "X")
  end
end
