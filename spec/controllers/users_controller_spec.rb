require "rails_helper"

RSpec.describe UsersController, type: :controller do
  context "when signed in as a basic PQ user" do
    before { sign_in create(:user) }

    it "redirects away from the user list" do
      get :index

      expect(response).to redirect_to root_path
    end

    it "redirects away from another user's details" do
      get :show, params: { id: create(:user, email: "other@justice.gov.uk").id }

      expect(response).to redirect_to root_path
    end

    it "redirects away from the edit form" do
      get :edit, params: { id: create(:user, email: "other@justice.gov.uk").id }

      expect(response).to redirect_to root_path
    end

    # The one that matters. user_params permits :roles, and the role select in
    # the UI only offers PQUSER, so the interface hides this rather than
    # preventing it — a crafted POST was all it took. Before auto-provisioning
    # an attacker needed an emailed invitation to get this far; afterwards,
    # anyone in the MoJ tenant can sign in and try.
    it "refuses to grant itself the admin role" do
      user = create(:user, email: "other@justice.gov.uk")

      patch :update, params: { id: user.id, user: { roles: "PQUSER,ADMIN" } }

      expect(user.reload.roles).to eq "PQUSER"
    end

    it "refuses to undelete a removed user" do
      removed = create(:user, email: "removed@justice.gov.uk", deleted: true)

      patch :update, params: { id: removed.id, user: { deleted: false } }

      expect(removed.reload.deleted).to be true
    end
  end

  context "when signed in as an admin" do
    before { sign_in create(:admin) }

    it "lists users" do
      get :index

      expect(response).to have_http_status :ok
    end

    # Confirms the gate did not cost admins the function it protects.
    it "can still update a user" do
      user = create(:user, email: "other@justice.gov.uk", name: "Old Name")

      patch :update, params: { id: user.id, user: { name: "New Name" } }

      expect(user.reload.name).to eq "New Name"
    end
  end

  context "when not signed in" do
    it "redirects to the sign in journey" do
      get :index

      expect(response).to redirect_to new_user_session_path
    end
  end
end
