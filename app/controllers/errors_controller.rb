class ErrorsController < ApplicationController
  def not_found
    update_page_title "Error - 404 - Page cannot be found"
    render status: :not_found
  end

  def internal_error
    update_page_title "Error - 500 - Internal server error"
    render status: :internal_server_error
  end
end
