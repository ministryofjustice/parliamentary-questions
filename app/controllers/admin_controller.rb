class AdminController < ApplicationController
  before_action :authenticate_user!

  def index
    update_page_title "Settings"
  end
end
