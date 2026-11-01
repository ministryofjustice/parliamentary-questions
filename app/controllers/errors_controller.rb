class ErrorsController < ApplicationController
  def not_found
    update_page_title "Error - 404 - Page cannot be found"
    render status: :not_found
  end

  def internal_error
    update_page_title "Error - 500 - Internal server error"
    render status: :internal_server_error
  end

  # Reached through config.exceptions_app for anything Rails maps to 422 —
  # most commonly a stale CSRF token. Without this route the response body was
  # empty, which a legitimate user can hit: the handoff's signed-out and
  # expired modes wait for a click, so that page can sit open long enough for
  # its authenticity token to expire.
  def unprocessable_content
    update_page_title t("errors.unprocessable_content.page_title")
    render status: :unprocessable_content
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
