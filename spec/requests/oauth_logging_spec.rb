require "rails_helper"

# The end-to-end version of spec/lib/filter_parameter_logging_spec.rb. That
# spec proves the filter redacts the right keys; this one proves the filter is
# actually applied to a real callback request, which is the guarantee that
# matters: the authorization code arrives as a query parameter on every single
# sign-in, and it is a replayable credential for its lifetime.
RSpec.describe "OAuth request logging", type: :request do
  def capture_rails_log
    io = StringIO.new
    original = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(io)
    ActionController::Base.logger = Rails.logger
    yield
    io.string
  ensure
    Rails.logger = original
    ActionController::Base.logger = original
  end

  it "does not write the authorization code or state to the log" do
    log = capture_rails_log do
      get "/users/auth/entra_id/callback?code=SUPERSECRETCODE&state=SUPERSECRETSTATE"
    end

    # Guards against passing vacuously: if nothing were logged at all, the two
    # absence assertions below would hold while proving nothing.
    expect(log).to include "Parameters:"

    expect(log).not_to include "SUPERSECRETCODE"
    expect(log).not_to include "SUPERSECRETSTATE"
    expect(log).to include "[FILTERED]"
  end
end
