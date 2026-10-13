class HealthCheckController < ApplicationController
  respond_to :json

  def index
    report = HealthCheckService.new.report

    if report.status == "200"
      render(json: { status: "ok" })
    else
      render(json: { status: "error" }, status: :internal_server_error)
    end
  end
end
