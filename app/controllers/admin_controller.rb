class AdminController < ApplicationController
    before_action :authenticate_user!, PQUserFilter

  def index

  end
end
