class AdminController < ApplicationController
  # Admins only: the Settings link is in the navigation for every PQ user, and
  # this page is the way through to the user administration screens.
  before_action :authenticate_admin!

  def index
    update_page_title "Settings"
  end
end
