module Features
  module SessionHelpers
    def create_pq_session
      sign_in_as(DbHelpers.users.find(&:pq_user?))
    end

    def create_admin_session
      sign_in_as(DbHelpers.users.find(&:admin?))
    end

    # The password argument is accepted and ignored, so the call sites above
    # and any spec still passing one keep working unchanged.
    def sign_in(email, _password = nil)
      sign_in_as(User.find_by!(email: email))
    end

    def sign_in_as(user)
      mock_entra_auth(oid: user.azure_oid, email: user.email, name: user.name)
      complete_entra_sign_in
    end

    # tid, aud and iss are read back out of Settings rather than hardcoded, so
    # the mocked response always satisfies AzureOauth::Claims. Claims fails
    # closed on a mismatch, so a hardcoded tenant here would silently turn
    # every feature spec's sign-in into a refusal if the configured value ever
    # changed.
    def mock_entra_auth(oid:, email:, name: "Test User")
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new(
        provider: "entra_id",
        uid: oid,
        info: { name: name, email: email },
        extra: {
          raw_info: {
            "oid" => oid,
            "tid" => Settings.omniauth_azure_tenant_id,
            "aud" => Settings.omniauth_azure_client_id,
            "iss" => Settings.azure_issuer,
            "email" => email,
            "name" => name,
          },
        },
      )
    end

    # OmniAuth turns a symbol into a failure rather than an auth hash, which
    # drives Users::OmniauthCallbacksController#failure.
    def mock_entra_failure(reason = :invalid_credentials)
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:entra_id] = reason
    end

    # Goes straight to the callback instead of through the interstitial. The
    # handoff submits itself with JavaScript, which does not run under
    # rack_test and would race a click under :js — neither is something 46
    # call sites should depend on. The interstitial is covered directly by
    # spec/controllers/users/oauth_handoff_controller_spec.rb, and
    # spec/features/authentication_spec.rb walks through it for real.
    #
    # Signing out first mirrors the previous password helper: it guarantees a
    # clean session when a spec switches user mid-example.
    def complete_entra_sign_in
      visit destroy_user_session_path
      visit user_entra_id_omniauth_callback_path
    end
  end
end
