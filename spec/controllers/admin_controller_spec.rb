require "rails_helper"

RSpec.describe AdminController, type: :controller do
  context "when signed in as a basic PQ user" do
    # The Settings link is in the navigation for every PQ user, so this page is
    # one click away for anyone who can sign in — and it is the route to the
    # user administration screens.
    it "redirects away from the settings page" do
      sign_in create(:user)

      get :index

      expect(response).to redirect_to root_path
    end
  end

  context "when signed in as an admin" do
    it "renders the settings page" do
      sign_in create(:admin)

      get :index

      expect(response).to have_http_status :ok
    end
  end

  context "when not signed in" do
    it "redirects to the sign in journey" do
      get :index

      expect(response).to redirect_to new_user_session_path
    end
  end
end
