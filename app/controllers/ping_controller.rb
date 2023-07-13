class PingController < ApplicationController
  def index
    Rails.logger.silence do
      render json: Deployment.info
    end
  end
end
