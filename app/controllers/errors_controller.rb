class ErrorsController < ApplicationController
  def not_found
    update_page_title "Error - 404 - Page cannot be found"
    render status: :not_found
  end

  def internal_error
    update_page_title "Error - 500 - Internal server error"
    render status: :internal_server_error
  end

  # One generic page for every sign-in failure mode. The reason is logged by
  # the callback and never reaches this page: a provider-supplied
  # error_description rendered into a PQ-branded page is a reflected-content
  # vector, and naming the failed check tells an attacker which claim to forge.
  def sign_in_failed
    update_page_title t("errors.sign_in_failed.page_title")
    render status: :forbidden
  end
end
