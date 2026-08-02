require "rails_helper"

describe Users::SessionsController, type: :controller do
  let(:password) { "123456789" }
  let!(:user) { create(:user, password:, password_confirmation: password) }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET new" do
    it "renders the sign in page" do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST create" do
    let(:credentials) { { email: user.email, password: } }

    context "when AUTH_METHODS=both (default)" do
      it "signs the user in with valid credentials" do
        post :create, params: { user: credentials }

        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when AUTH_METHODS=password_only" do
      before { set_auth_methods("password_only") }

      it "signs the user in with valid credentials" do
        post :create, params: { user: credentials }

        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when AUTH_METHODS=sso_only" do
      before { set_auth_methods("sso_only") }

      it "blocks password sign in even with valid credentials" do
        post :create, params: { user: credentials }

        expect(controller.current_user).to be_nil
        expect(flash[:alert]).to eq("Signing in with a password is disabled. Please sign in with your Justice account.")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
