class PingController  < ApplicationController
  respond_to :json

  def index
    Rails.logger.silence do
      respond_with Deployment.info
    end
  end
end
