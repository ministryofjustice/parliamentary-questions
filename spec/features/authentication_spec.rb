require "feature_helper"

describe "authentication" do
  let!(:pq_user) { DbHelpers.users.find(&:pq_user?) }

  it "takes an unauthenticated visitor into the OAuth journey" do
    visit dashboard_path

    expect(page).to have_current_path "/users/sign_in"
    expect(page).to have_button "Continue to sign in"
  end

  it "never shows a password field" do
    visit dashboard_path

    expect(page).to have_no_field "Password (required)"
  end

  # Exercises the interstitial for real, rather than going straight to the
  # callback the way the sign-in helper does, and proves the ordering in
  # Users::OmniauthCallbacksController: stored_location_for is read BEFORE
  # reset_session, so the deep link that triggered the journey survives it.
  it "returns the user to the page that sent them to sign in" do
    visit dashboard_backlog_path
    expect(page).to have_current_path "/users/sign_in"

    mock_entra_auth(oid: pq_user.azure_oid, email: pq_user.email, name: pq_user.name)
    click_button "Continue to sign in"

    expect(page).to have_current_path dashboard_backlog_path
  end

  # The regression test for the bounce: an auto-submitting handoff would sign
  # the user straight back in off the surviving Entra session and make the
  # "Sign out" nav item a lie.
  it "confirms a sign out instead of signing the user straight back in" do
    create_pq_session
    visit dashboard_path

    click_link "Sign out"

    expect(page).to have_content "You have been signed out"
    expect(page).to have_no_link "Sign out"
  end

  it "stays signed out until the user asks to sign in again" do
    create_pq_session
    visit dashboard_path
    click_link "Sign out"

    visit dashboard_path

    expect(page).to have_current_path "/users/sign_in"
  end

  it "provisions an unknown tenant user as a basic PQ user" do
    mock_entra_auth(oid: "oid-brand-new", email: "brand.new@justice.gov.uk", name: "Brand New")

    expect { complete_entra_sign_in }.to change(User, :count).by(1)

    expect(User.find_by(azure_oid: "oid-brand-new").roles).to eq User::ROLE_PQ_USER
  end

  it "signs an existing user in against their oid without creating a second row" do
    mock_entra_auth(oid: pq_user.azure_oid, email: pq_user.email, name: pq_user.name)

    expect { complete_entra_sign_in }.not_to change(User, :count)

    visit dashboard_path
    expect(page).to have_link "Sign out"
  end

  it "sends a failed sign in to the support page" do
    mock_entra_failure(:invalid_credentials)

    complete_entra_sign_in

    expect(page).to have_current_path "/sign_in_failed"
    expect(page).to have_content "contact"
  end

  it "reactivates a returning removed user as a basic user" do
    admin = DbHelpers.users.find(&:admin?)
    admin.update!(deleted: true)

    mock_entra_auth(oid: admin.azure_oid, email: admin.email, name: admin.name)

    expect { complete_entra_sign_in }.not_to change(User, :count)

    expect(admin.reload).to have_attributes(deleted: false, roles: User::ROLE_PQ_USER)
  end

  # The flag is the escape hatch, so it has to be proven to still work rather
  # than merely still exist.
  context "when password login is enabled" do
    before do
      allow(Settings).to receive(:password_login_enabled?).and_return(true)
      Rails.application.reload_routes!
    end

    after { Rails.application.reload_routes! }

    it "still allows signing in with a password" do
      visit new_user_session_path
      fill_in "Email (required)", with: pq_user.email
      fill_in "Password (required)", with: DbHelpers::USER_PASSWORD
      click_button "Sign in"

      visit dashboard_path
      expect(page).to have_link "Sign out"
    end
  end
end
