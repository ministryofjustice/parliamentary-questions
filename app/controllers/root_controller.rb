class RootController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to controller: "dashboard", action: "index"
  end
end
