class AdminController < ApplicationController
    before_action :authenticate_user!, PQUserFilter

  def index
    update_page_title 'Settings'
  end
end
