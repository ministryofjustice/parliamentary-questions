# Azure Entra ID OAuth Sign-in Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace PQ Tracker's email/password sign-in with OAuth 2.0 Authorization Code flow against Microsoft Entra ID, keyed on the immutable `oid` claim, with the password path retained behind a feature flag.

**Architecture:** OmniAuth + `omniauth-rails_csrf_protection` behind Devise's `omniauthable` module. Two pure service objects carry the logic — `AzureOauth::Claims` validates the response's `tid`/`aud`/`iss` and exposes the claims; `AzureOauth::UserResolver` maps an `oid` to a `User`, provisioning or reactivating as needed — so the controller stays thin and the security-critical decisions are unit-testable without HTTP. A `Users::OauthHandoffController` occupies the `new_user_session` route name, which is what makes Devise's existing `authenticate_user!` redirect land users in the OAuth journey automatically without touching 26 controllers.

**Tech Stack:** Rails 8.1.3, Ruby 4.0.3, Devise ~> 5.0, `devise_invitable ~> 2.0`, `omniauth-entra-id`, `omniauth-rails_csrf_protection`, RSpec + Capybara, Slim views, PostgreSQL.

**Spec:** `docs/specs/2026-10-29-azure-oauth-design.md`

## Global Constraints

- Rubocop follows `rubocop-govuk` (`.rubocop.yml` inherits `config/default.yml`, `config/rails.yml`, `config/rspec.yml`). Do not add overrides to `.rubocop.yml`.
- Views are Slim. Error and interstitial pages use the GOV.UK classes already in `app/views/errors/not_found.html.slim`: `.govuk-width-container`, `h1.govuk-heading-xl`, `p.govuk-body`.
- Support address comes from `Settings.mail_tech_support` (`PQsupport-gg@justice.gov.uk`), never hardcoded in new code.
- `LogStuff.warn` / `.error` / `.info` **require a block** — `LogStuff.log` returns early `unless block_given?`. Always `LogStuff.warn(:oauth) { "message" }`. (`app/controllers/users/invitations_controller.rb:7` passes a bare string and therefore logs nothing; do not copy that form.)
- Never log or render an authorization code, token, client secret, or raw provider error text.
- Credentials: `OMNIAUTH_AZURE_TENANT_ID`, `OMNIAUTH_AZURE_CLIENT_ID`, `OMNIAUTH_AZURE_CLIENT_SECRET`. The first two are public identifiers and belong in committed configmaps; the secret belongs in `pq-secrets` and must never be committed.
- Flags: `OAUTH_AZURE_ENABLED`, `PASSWORD_LOGIN_ENABLED`.
- Scopes requested: `"openid profile email"`. No Microsoft Graph permissions.
- **Amended 2026-10-30:** the gem is `omniauth-entra-id` 3.1.1 and the strategy
  name is `entra_id`, not `azure_activedirectory_v2` — the originally planned
  gem is deprecated. Registered with `ignore_tid: true`. All claims (`oid`,
  `tid`, `aud`, `iss`, `email`, `upn`, `preferred_username`, `name`) are read
  from `extra.raw_info`; `info.email` performs no fallback. The gem verifies
  `aud`/`iss`/`exp`/`nbf` but not the signature, and never `tid`. See the
  Amendment section of the spec.
- The OmniAuth `:developer` strategy may be registered **only** when `Rails.env.development?`.
- Do not add authentication to `AssignmentController` (uses `AoTokenFilter`) or `ProposalsController` (has its own private `authenticate_user`, unrelated to Devise). These serve external action officers with no tenant identity.
- **Committing is suspended by instruction from the repository owner.** Each task ends with a `git commit` command for when that instruction is lifted; until then, run every verification step but stop short of `git add`/`git commit`, and leave the work in the working tree. Never push and never open a PR.

## Review Focus

Failure modes the spec implies that no task's happy path covers. Each has a test assigned to the task that owns the code.

1. **Concurrent first sign-in** — a double-clicked handoff button fires two callbacks for a user with no `azure_oid`; both pass the email match and both try to write it, and the unique index turns the loser into a 500 instead of a sign-in. Covered in Task 5.
2. **Entra email case differing from the stored email** — Entra returns `Jane.Smith@justice.gov.uk`, PQ holds `jane.smith@justice.gov.uk`. A case-sensitive match would provision a duplicate account and then fail email uniqueness validation. Covered in Task 5.
3. **Handoff requested while already signed in** — an auto-submitting page reachable by a signed-in user is a redirect loop. Covered in Task 7.
4. **OmniAuth failure with no error object** — `#failure` reading `request.env["omniauth.error"].message` raises `NoMethodError` on `access_denied`, where OmniAuth sets a strategy and message but no exception. Covered in Task 8.
5. **An email reassigned in the tenant to a different human, matching a soft-deleted row** — trust-on-first-use links the new person's `oid` to the departed person's row and undeletes it, so they inherit that history. The agreed rule says undelete, so this is accepted rather than blocked, but every email-based link must be logged at warn level with both the `oid` and the row id so it is auditable after the fact. Covered in Task 5.

---

### Task 1: Settings flags and Azure credentials

**Files:**
- Modify: `lib/settings.rb:31-89` (add accessors to the `module_function` section)
- Test: `spec/lib/settings_spec.rb` (create)

**Interfaces:**
- Produces: `Settings.oauth_azure_enabled?` → `Boolean`; `Settings.password_login_enabled?` → `Boolean`; `Settings.omniauth_azure_tenant_id` / `omniauth_azure_client_id` / `omniauth_azure_client_secret` → `String | nil`; `Settings.azure_issuer` → `String` (`"https://login.microsoftonline.com/#{tenant_id}/v2.0"`).

Flag defaults are deliberate: `oauth_azure_enabled?` defaults **true**, `password_login_enabled?` defaults **true for now**. Task 11 flips the password default to `false` once the test suite no longer depends on the form. Keeping it true here is what lets Tasks 1–10 each land with a green suite.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/lib/settings_spec.rb
require "spec_helper"

RSpec.describe Settings do
  describe ".oauth_azure_enabled?" do
    it "defaults to true when unset"
    it "is false when OAUTH_AZURE_ENABLED is 'false'"
    it "is true when OAUTH_AZURE_ENABLED is 'true'"
  end

  describe ".password_login_enabled?" do
    it "defaults to true when unset"
    it "is false when PASSWORD_LOGIN_ENABLED is 'false'"
  end

  describe ".azure_issuer" do
    it "builds the v2.0 issuer URL from the tenant id" do
      ClimateControl.modify(OMNIAUTH_AZURE_TENANT_ID: "tenant-abc") do
        expect(described_class.azure_issuer)
          .to eq "https://login.microsoftonline.com/tenant-abc/v2.0"
      end
    end
  end
end
```

Use `ClimateControl.modify` if the gem is already available; otherwise stub with `allow(ENV).to receive(:fetch).and_call_original` plus a targeted override, or add `climate_control` to the `:test` group — the implementer's choice, but ENV must be restored after each example.

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/lib/settings_spec.rb`
Expected: FAIL with `NoMethodError: undefined method 'oauth_azure_enabled?'`

- [ ] **Step 3: Implement the accessors in `lib/settings.rb`**

Read ENV lazily inside each method — `Settings` is required at the bottom of `config/application.rb`, and the existing `@pq_rest_api` eager pattern would freeze flag values at boot. Booleans compare against the string `"true"`.

- [ ] **Step 4: Add production credential validation**

Follow the shape of `Settings::PqRestApi.from_env:12-19`: when `ENV["RAILS_ENV"] == "production"` and `oauth_azure_enabled?`, raise if any of the three credentials is blank. Failing at boot beats failing at a user's first sign-in.

- [ ] **Step 5: Run tests and rubocop**

Run: `bundle exec rspec spec/lib/settings_spec.rb && bundle exec rubocop lib/settings.rb spec/lib/settings_spec.rb`
Expected: PASS, no offenses

- [ ] **Step 6: Commit**

```bash
git add lib/settings.rb spec/lib/settings_spec.rb Gemfile Gemfile.lock
git commit -m "CDPTKAN-1183 Add OAuth feature flags and Azure credential settings"
```

---

### Task 2: Gems, provider registration, and the developer-strategy guard

**Files:**
- Modify: `Gemfile`, `Gemfile.lock`
- Modify: `config/initializers/devise.rb:241-248` (the OmniAuth section)
- Modify: `app/models/user.rb:48-56` (the `devise` call)
- Test: `spec/models/user_spec.rb` (modify), `spec/lib/omniauth_configuration_spec.rb` (create)

**Interfaces:**
- Consumes: `Settings.oauth_azure_enabled?`, `Settings.omniauth_azure_*` from Task 1.
- Produces: `User.omniauth_providers` → `Array<Symbol>`; the route `/users/auth/entra_id` and its `callback`; `omniauth_authorize_path(:user, :entra_id)`.

- [ ] **Step 1: Add the gems**

```ruby
gem "omniauth-entra-id"
gem "omniauth-rails_csrf_protection"
```

Let Bundler resolve versions against Rails 8.1 / Ruby 4.0 rather than copying the sibling app's pins (`omniauth 2.1.4`, `omniauth-entra-id 1.0.0`). Run `bundle install`.

- [ ] **Step 2: Inspect the installed strategy before relying on it**

Run: `bundle show omniauth-entra-id` and read the strategy source. Record, in a comment at the top of `app/services/azure_oauth/claims.rb` when Task 4 creates it, where `oid`, `tid`, `aud`, `iss`, `email`, `preferred_username` and `name` actually sit in the auth hash (`uid`, `info`, `extra.raw_info`), and whether the gem verifies the `id_token` signature or relies on having received it over TLS from the token endpoint. Tasks 4 and 5 are written against the expected shape; correct them to the real one.

- [ ] **Step 3: Write the failing test**

```ruby
# spec/lib/omniauth_configuration_spec.rb
require "spec_helper"

RSpec.describe "OmniAuth configuration" do
  it "registers the Azure provider" do
    expect(User.omniauth_providers).to include(:entra_id)
  end

  it "does not register the developer strategy outside development" do
    expect(Rails.env.development?).to be false
    expect(User.omniauth_providers).not_to include(:developer)
  end

  it "exposes a POST-only authorize route" do
    expect(Rails.application.routes.url_helpers
      .user_entra_id_omniauth_authorize_path)
      .to eq "/users/auth/entra_id"
  end
end
```

The second example is the guard that keeps a forgeable identity out of deployed environments. It must stay in the suite permanently.

- [ ] **Step 4: Run test to verify it fails**

Run: `bundle exec rspec spec/lib/omniauth_configuration_spec.rb`
Expected: FAIL — `User.omniauth_providers` raises `NoMethodError`

- [ ] **Step 5: Add `:omniauthable` to `User`**

Append `:omniauthable, omniauth_providers: OmniAuth.strategies.map(...)` — or simpler, a constant built from the same condition the initializer uses. The provider list must include `:developer` **only** when `Rails.env.development?`. Keep `validate_on_invite: true` last, as now.

- [ ] **Step 6: Register the providers in `config/initializers/devise.rb`**

Replace the commented example at line 244. Register `:entra_id` with `tenant_id:`, `client_id:`, `client_secret:` and `scope: "openid profile email"`, guarded by `Settings.oauth_azure_enabled?`. Register `:developer` guarded by `Rails.env.development?`. Also set `OmniAuth.config.failure_raise_out_environments = []` so development routes failures to the error page rather than raising.

- [ ] **Step 7: Run tests and rubocop**

Run: `bundle exec rspec spec/lib/omniauth_configuration_spec.rb spec/models/user_spec.rb && bundle exec rubocop`
Expected: PASS, no offenses

- [ ] **Step 8: Commit**

```bash
git add Gemfile Gemfile.lock config/initializers/devise.rb app/models/user.rb spec/lib/omniauth_configuration_spec.rb spec/models/user_spec.rb
git commit -m "CDPTKAN-1183 Register Azure OmniAuth provider behind Devise"
```

---

### Task 3: The `azure_oid` column

**Files:**
- Create: `db/migrate/<timestamp>_add_azure_oid_to_users.rb`
- Modify: `db/schema.rb` (generated)
- Modify: `app/models/user.rb` (schema annotation comment at lines 3-33)
- Test: `spec/models/user_spec.rb`

**Interfaces:**
- Produces: `users.azure_oid` — `string`, nullable, unique index.

Nullable because every existing row has no `oid` until its owner first signs in. Unique because it is what makes the trust-on-first-use link unclaimable twice, including under the race in Review Focus 1.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/models/user_spec.rb
it { is_expected.to have_db_column(:azure_oid).of_type(:string) }
it { is_expected.to have_db_index(:azure_oid).unique(true) }
```

`shoulda-matchers` is already configured in `spec/rails_helper.rb:4-11`.

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/models/user_spec.rb -e azure_oid`
Expected: FAIL — column does not exist

- [ ] **Step 3: Generate and write the migration**

Run `bin/rails generate migration AddAzureOidToUsers`, then add the column and a unique index. Inherit from `ActiveRecord::Migration[8.1]`.

- [ ] **Step 4: Migrate and verify the schema**

Run: `bin/rails db:migrate && bin/rails db:test:prepare`
Expected: `db/schema.rb` version bumps past `2026_05_29_102813` and shows `azure_oid` on `users`

- [ ] **Step 5: Refresh the schema annotation**

The `annotate` comment blocks at the top of `app/models/user.rb` and `spec/factories/users.rb` list every column. Update both to include `azure_oid`.

- [ ] **Step 6: Run tests**

Run: `bundle exec rspec spec/models/user_spec.rb`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add db/migrate db/schema.rb app/models/user.rb spec/factories/users.rb spec/models/user_spec.rb
git commit -m "CDPTKAN-1183 Add azure_oid to users"
```

---

### Task 4: `AzureOauth::Claims`

**Files:**
- Create: `app/services/azure_oauth/claims.rb`
- Test: `spec/services/azure_oauth/claims_spec.rb`

**Interfaces:**
- Consumes: `Settings.omniauth_azure_tenant_id`, `Settings.omniauth_azure_client_id`, `Settings.azure_issuer` from Task 1.
- Produces: `AzureOauth::Claims.new(auth_hash)` with `#valid?` → `Boolean`, `#error` → `Symbol | nil`, `#oid` → `String`, `#email` → `String | nil`, `#name` → `String | nil`.

`#oid` returns the claim downcased and stripped; Entra sends a lowercase GUID, and normalising on the way in means a variant spelling can never create a second row for the same human. `#email` falls back to `preferred_username` when `email` is absent. `#error` returns the first failed check as a symbol — `:tenant_mismatch`, `:audience_mismatch`, `:issuer_mismatch`, `:missing_oid` — for logging only; it is never rendered.

The `:developer` strategy produces none of these claims. Treat a `developer` provider as valid when the `uid` is present, and prefix its `oid` with `dev-` so a development identity can never collide with a real Entra `oid`.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/services/azure_oauth/claims_spec.rb
require "rails_helper"

RSpec.describe AzureOauth::Claims do
  # build an auth hash with the right shape, overridable per example
  def auth_hash(provider: "entra_id", **claims) = ...

  describe "#valid?" do
    it "is true for a response from the configured tenant with the configured audience"
    it "is false when tid does not match the configured tenant" # error == :tenant_mismatch
    it "is false when aud does not match the configured client id" # error == :audience_mismatch
    it "is false when iss is not the expected issuer for the tenant" # error == :issuer_mismatch
    it "is false when oid is blank" # error == :missing_oid
  end

  describe "#oid" do
    it "downcases and strips the claim" do
      expect(described_class.new(auth_hash(oid: "  ABC-123  ")).oid).to eq "abc-123"
    end
  end

  describe "#email" do
    it "returns the email claim when present"
    it "falls back to preferred_username when email is absent"
    it "is nil when neither is present"
  end

  describe "with the developer provider" do
    it "is valid on uid alone, with no tenant claims"
    it "prefixes the oid with 'dev-'"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/services/azure_oauth/claims_spec.rb`
Expected: FAIL — `uninitialized constant AzureOauth::Claims`

- [ ] **Step 3: Implement `AzureOauth::Claims`**

A plain class under `app/services/azure_oauth/` — Zeitwerk resolves the namespace from the directory, as `lib/pqa/` and `lib/export/` already do. Compare strings with `ActiveSupport::SecurityUtils.secure_compare` where convenient but do not contort the code for it; these are not secrets, and a timing side-channel on a tenant GUID buys an attacker nothing.

- [ ] **Step 4: Run tests and rubocop**

Run: `bundle exec rspec spec/services/azure_oauth/claims_spec.rb && bundle exec rubocop app/services/azure_oauth spec/services/azure_oauth`
Expected: PASS, no offenses

- [ ] **Step 5: Commit**

```bash
git add app/services/azure_oauth/claims.rb spec/services/azure_oauth/claims_spec.rb
git commit -m "CDPTKAN-1183 Add Azure claim validation"
```

---

### Task 5: `AzureOauth::UserResolver`

**Files:**
- Create: `app/services/azure_oauth/user_resolver.rb`
- Test: `spec/services/azure_oauth/user_resolver_spec.rb`

**Interfaces:**
- Consumes: `AzureOauth::Claims` from Task 4; `User::ROLE_PQ_USER`; `SoftDeletion::Record#activate!` (`app/models/soft_deletion.rb:13`).
- Produces: `AzureOauth::UserResolver.new(claims).call` → `User`, or raises `AzureOauth::UserResolver::IdentityConflict`.

This task owns the whole identity decision and is the most important one in the plan. Every lookup must include soft-deleted rows — `User` has no `default_scope`, so plain finders already do, but do not reach for the `active` scope out of habit.

Resolution order:

1. `User.find_by(azure_oid: oid)` → that user. Identity settled.
2. Otherwise case-insensitive email match (`where("lower(email) = ?", email.downcase)`):
   - if that row holds a different non-nil `azure_oid`, raise `IdentityConflict`;
   - otherwise write `azure_oid`, and log at warn level with the `oid` and the row id — this is the audit trail for Review Focus 5.
3. Otherwise create with `azure_oid`, `email`, `name`, `roles: User::ROLE_PQ_USER`, and `password: Devise.friendly_token(64)`. The random password exists only to satisfy `:validatable`; nobody can know it, and Task 9's routing leaves no endpoint that would accept it.

Then, for an existing row: if `deleted?`, `activate!` **and** set `roles` to `User::ROLE_PQ_USER` — a returning removed user comes back as a basic user whatever they were before. Clear any `lockable` lock unconditionally; `failed_attempts` counts failed *password* attempts, which cannot grow with the password route gone, and the unlock route is not mounted, so a pre-cutover lock would otherwise strand its owner permanently. Finally sync `name` and `email`.

`name` falls back to the email local part when Entra sends none, because `User` validates `name` presence (`app/models/user.rb:58`). When creating and both `email` and `preferred_username` are absent, raise `IdentityConflict` — `:validatable` requires an email and PQ sends notifications to it.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/services/azure_oauth/user_resolver_spec.rb
require "rails_helper"

RSpec.describe AzureOauth::UserResolver do
  describe "#call" do
    context "when a user already holds the oid" do
      it "returns that user"
      it "does not create a new user"
    end

    context "when no user holds the oid but one matches on email" do
      it "writes the oid to that user"
      it "matches case-insensitively" # Entra "Jane.Smith@..." vs stored "jane.smith@..."
      it "logs a warning naming the oid and the user id"
      it "does not create a new user"
    end

    context "when the email-matched user already holds a different oid" do
      it "raises IdentityConflict"
      it "leaves the existing azure_oid untouched"
    end

    context "when nothing matches" do
      it "creates a user with roles PQUSER"
      it "stores the oid, email and name"
      it "sets an unguessable password so the record validates"
    end

    context "when the matched user is soft deleted" do
      it "undeletes the same row rather than creating a second one" do
        # expect { resolver.call }.not_to change(User, :count)
      end
      it "resets roles to PQUSER even if they were an admin"
    end

    context "when the matched user is locked" do
      it "clears the lock and returns the user"
    end

    context "when Entra sends no name" do
      it "falls back to the email local part"
    end

    context "when Entra sends neither email nor preferred_username" do
      it "raises IdentityConflict for a new user"
    end

    context "when the synced email collides with another user" do
      it "returns the oid-matched user signed in" # identity is proven; email is cosmetic
      it "leaves the existing email in place"
      it "logs a warning"
    end

    context "when two callbacks race to claim the same oid" do
      it "returns the winning row instead of raising" do
        # Simulate by stubbing the insert to raise ActiveRecord::RecordNotUnique
        # once, then asserting #call re-reads by oid and returns that user.
      end
    end
  end
end
```

The racing example is Review Focus 1. A double-clicked handoff button produces exactly this, and without the rescue the second request is a 500 on a successful login.

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/services/azure_oauth/user_resolver_spec.rb`
Expected: FAIL — `uninitialized constant AzureOauth::UserResolver`

- [ ] **Step 3: Implement `AzureOauth::UserResolver`**

Wrap the resolution in a transaction. Rescue `ActiveRecord::RecordNotUnique` on the `azure_oid` write and re-read by `oid`, returning the winner. Rescue the email-uniqueness case at the model-validation level rather than the DB level — check for a colliding row before assigning, so the sync can be skipped without aborting the transaction.

- [ ] **Step 4: Run tests and rubocop**

Run: `bundle exec rspec spec/services/azure_oauth && bundle exec rubocop app/services/azure_oauth spec/services/azure_oauth`
Expected: PASS, no offenses

- [ ] **Step 5: Commit**

```bash
git add app/services/azure_oauth/user_resolver.rb spec/services/azure_oauth/user_resolver_spec.rb
git commit -m "CDPTKAN-1183 Add Azure identity resolution and auto-provisioning"
```

---

### Task 6: The sign-in failure page

**Files:**
- Modify: `app/controllers/errors_controller.rb`
- Create: `app/views/errors/sign_in_failed.html.slim`
- Modify: `config/routes.rb` (beside `get "/404"` and `get "/500"` at the bottom)
- Modify: `config/locales/en.yml`
- Test: `spec/controllers/errors_controller_spec.rb`

**Interfaces:**
- Produces: `ErrorsController#sign_in_failed` responding 403; route helper `sign_in_failed_path` at `/sign_in_failed`.

Follow the structure of `app/views/errors/not_found.html.slim` exactly — `.govuk-width-container`, `main#main-content.govuk-main-wrapper[role="main"]`, `h1.govuk-heading-xl`, `p.govuk-body` — and link `Settings.mail_tech_support` as a `mailto:`, rather than hardcoding the address the way the 404 page does.

The page carries no provider text, no claim values, and no link back into the handoff. A retry link on a page reached by a failing retry is how you build a loop.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/controllers/errors_controller_spec.rb
context "when sign in failed" do
  it "renders the expected template" do
    get :sign_in_failed
    expect(response).to render_template(:sign_in_failed)
  end

  it "responds forbidden" do
    get :sign_in_failed
    expect(response).to be_forbidden
  end

  it "does not render provider-supplied text" do
    get :sign_in_failed, params: { error_description: "<script>alert(1)</script>" }
    expect(response.body).not_to include "alert(1)"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/controllers/errors_controller_spec.rb`
Expected: FAIL — no route matches `sign_in_failed`

- [ ] **Step 3: Add the route, action and view**

Action mirrors the two existing ones: `update_page_title`, then `render status: :forbidden`. Copy goes in `config/locales/en.yml` so it is not buried in the template: a heading saying sign-in could not be completed, a line saying the user's account may not have access, and a line directing them to support.

- [ ] **Step 4: Run tests and rubocop**

Run: `bundle exec rspec spec/controllers/errors_controller_spec.rb && bundle exec rubocop`
Expected: PASS, no offenses

- [ ] **Step 5: Commit**

```bash
git add app/controllers/errors_controller.rb app/views/errors/sign_in_failed.html.slim config/routes.rb config/locales/en.yml spec/controllers/errors_controller_spec.rb
git commit -m "CDPTKAN-1183 Add sign-in failure page"
```

---

### Task 7: The handoff interstitial

**Files:**
- Create: `app/controllers/users/oauth_handoff_controller.rb`
- Create: `app/views/users/oauth_handoff/new.html.slim`
- Modify: `config/routes.rb`
- Modify: `config/locales/en.yml`
- Test: `spec/controllers/users/oauth_handoff_controller_spec.rb` (create), `spec/requests/omniauth_request_phase_spec.rb` (create)

**Interfaces:**
- Consumes: `omniauth_authorize_path(:user, :entra_id)` from Task 2.
- Produces: `Users::OauthHandoffController#new`; assigns `@mode` → one of `:fresh`, `:signed_out`, `:expired`.

Why an interstitial rather than a redirect: `omniauth-rails_csrf_protection` requires the request phase to be a POST carrying a valid authenticity token — the fix for CVE-2015-9284. A `redirect_to "/users/auth/entra_id"` is rejected.

The three modes:

| `@mode` | Reached from | Auto-submits |
| --- | --- | --- |
| `:fresh` | any unauthenticated request | yes |
| `:signed_out` | an explicit sign-out | no |
| `:expired` | a session timeout | no |

Detection: `:expired` when `flash[:timedout]` is set — Devise's `FailureApp` already sets it when the Warden message is `:timeout`. `:signed_out` from a marker set by `after_sign_out_path_for` in Task 9. Otherwise `:fresh`.

Without the split, sign-out and `config.timeout_in` (`config/initializers/devise.rb:192`, 60 minutes) have no observable effect: the Entra session outlives the PQ one, so an auto-submitting page hands the user straight back in.

A signed-in user requesting this page is redirected to `root_path` — an auto-submitting page reachable by a signed-in user is a loop (Review Focus 3).

- [ ] **Step 1: Write the failing test**

```ruby
# spec/controllers/users/oauth_handoff_controller_spec.rb
require "rails_helper"

RSpec.describe Users::OauthHandoffController, type: :controller do
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  describe "GET new" do
    it "renders a form that POSTs to the authorize path" do
      get :new
      expect(response.body)
        .to include 'action="/users/auth/entra_id"'
      expect(response.body).to include 'method="post"'
    end

    it "includes an auto-submit script on a fresh arrival" do
      get :new
      expect(assigns(:mode)).to eq :fresh
      expect(response.body).to include "submit()"
    end

    it "omits the auto-submit script after a session timeout" do
      flash[:timedout] = true
      get :new
      expect(assigns(:mode)).to eq :expired
      expect(response.body).not_to include "submit()"
    end

    it "omits the auto-submit script after an explicit sign out" do
      get :new, params: { signed_out: "1" }
      expect(assigns(:mode)).to eq :signed_out
      expect(response.body).not_to include "submit()"
    end

    it "redirects a signed-in user to root" do
      sign_in create(:user)
      get :new
      expect(response).to redirect_to root_path
    end
  end
end
```

Plus a request spec proving the protection the interstitial exists for is actually on, since a silent regression here reopens CVE-2015-9284:

```ruby
# spec/requests/omniauth_request_phase_spec.rb
RSpec.describe "the OmniAuth request phase", type: :request do
  it "rejects a GET to the authorize path" do
    get "/users/auth/entra_id"
    expect(response).not_to redirect_to %r{login\.microsoftonline\.com}
  end

  it "rejects a POST with no authenticity token" do
    # with ActionController::Base.allow_forgery_protection temporarily true
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/controllers/users/oauth_handoff_controller_spec.rb`
Expected: FAIL — `uninitialized constant Users::OauthHandoffController`

- [ ] **Step 3: Add the route**

Inside a `devise_scope :user do ... end` block, `get "/users/oauth_handoff" => "users/oauth_handoff#new"`. Task 9 re-points `new_user_session` at it; a plain path here keeps this task independently testable.

- [ ] **Step 4: Implement the controller and view**

The view renders a `button_to` to `omniauth_authorize_path(:user, :entra_id)` with `method: :post`, inside the standard application layout. The button carries visible text and is never hidden — it is the no-JS and assistive-technology path. Auto-submit is an inline `javascript_tag nonce: true`, rendered only when `@mode == :fresh`. The nonce is required: CSP sets `script_src :self, :unsafe_eval, googletagmanager` with `nonce_directives = %w[script-src]` (`config/initializers/content_security_policy.rb:14-21`). No CSP change is needed — `form-action` is unset and the form posts same-origin.

Copy per mode goes in `config/locales/en.yml`: "Signing you in…" for `:fresh`, "You have been signed out" for `:signed_out`, "Your session has expired" for `:expired`. The `:fresh` copy is on screen for however long Azure takes, so it must read as progress rather than as a broken page.

- [ ] **Step 5: Run tests and rubocop**

Run: `bundle exec rspec spec/controllers/users/oauth_handoff_controller_spec.rb spec/requests/omniauth_request_phase_spec.rb && bundle exec rubocop`
Expected: PASS, no offenses

- [ ] **Step 6: Commit**

```bash
git add app/controllers/users/oauth_handoff_controller.rb app/views/users/oauth_handoff config/routes.rb config/locales/en.yml spec/controllers/users/oauth_handoff_controller_spec.rb spec/requests/omniauth_request_phase_spec.rb
git commit -m "CDPTKAN-1183 Add OAuth handoff interstitial"
```

---

### Task 8: The OmniAuth callback

**Files:**
- Create: `app/controllers/users/omniauth_callbacks_controller.rb`
- Modify: `config/routes.rb:23` (add `omniauth_callbacks:` to the `devise_for` controllers hash)
- Test: `spec/controllers/users/omniauth_callbacks_controller_spec.rb` (create)

**Interfaces:**
- Consumes: `AzureOauth::Claims` (Task 4), `AzureOauth::UserResolver` (Task 5), `sign_in_failed_path` (Task 6).
- Produces: `Users::OmniauthCallbacksController#entra_id`, `#developer`, `#failure`.

Carry `skip_before_action :set_paper_trail_whodunnit` across from `Users::SessionsController:2` — there is no `current_user` yet.

Order of operations:

1. Read `request.env["omniauth.auth"]`. The `state` parameter has already been verified by `omniauth-oauth2` middleware; do not re-check it and do not touch the session before this point.
2. Build `AzureOauth::Claims`. If invalid, log `#error` and redirect to `sign_in_failed_path`.
3. Resolve the user. On `IdentityConflict`, log and redirect to `sign_in_failed_path`.
4. Capture `stored_location_for(:user)` **before** `reset_session`, then `reset_session`, then `sign_in_and_redirect` to the captured location or `root_path`.

Step 4's ordering is the whole point: `stored_location_for` reads from the session, so capturing it after the reset loses the user's deep link. The explicit `reset_session` mirrors what `Users::SessionsController#create` does for passwords — Devise does not rotate the session on sign-in by itself, which is why that override exists.

`#developer` delegates to the same private method, so the development path exercises the real code.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/controllers/users/omniauth_callbacks_controller_spec.rb
require "rails_helper"
require "devise"

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = valid_auth_hash
  end

  describe "GET entra_id" do
    it "signs in a user whose oid is known"
    it "redirects to the stored location when one was saved"
    it "redirects to root when no location was stored"
    it "rotates the session id on sign in" # fixation
    it "preserves the stored location across the session reset"

    it "redirects to the failure page when the tenant does not match"
    it "redirects to the failure page when the audience does not match"
    it "redirects to the failure page when the oid is missing"
    it "redirects to the failure page on IdentityConflict"
    it "does not sign anyone in when validation fails"
    it "logs the reason without rendering it"
  end

  describe "GET failure" do
    it "redirects to the failure page" do
      request.env["omniauth.error.type"] = :invalid_credentials
      get :failure
      expect(response).to redirect_to sign_in_failed_path
    end

    it "survives a failure with no error object" do
      request.env["omniauth.error.type"] = :access_denied
      request.env["omniauth.error"] = nil
      expect { get :failure }.not_to raise_error
      expect(response).to redirect_to sign_in_failed_path
    end
  end
end
```

The last example is Review Focus 4: on `access_denied` — a user clicking "Cancel" at the Microsoft prompt — OmniAuth sets a type and a strategy but no exception, so any `#failure` that reads `omniauth.error.message` raises `NoMethodError` and turns a routine cancellation into a 500.

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/controllers/users/omniauth_callbacks_controller_spec.rb`
Expected: FAIL — `uninitialized constant Users::OmniauthCallbacksController`

- [ ] **Step 3: Wire the controller into `devise_for`**

Add `omniauth_callbacks: "users/omniauth_callbacks"` to the existing hash at `config/routes.rb:23`.

- [ ] **Step 4: Implement the controller**

Subclass `Devise::OmniauthCallbacksController`. Log every refusal through `LogStuff.warn(:oauth) { ... }` — block form, per Global Constraints — including the `oid` where one is available, and never the raw provider payload.

- [ ] **Step 5: Run tests and rubocop**

Run: `bundle exec rspec spec/controllers/users && bundle exec rubocop`
Expected: PASS, no offenses

- [ ] **Step 6: Commit**

```bash
git add app/controllers/users/omniauth_callbacks_controller.rb config/routes.rb spec/controllers/users/omniauth_callbacks_controller_spec.rb
git commit -m "CDPTKAN-1183 Add Azure OmniAuth callback controller"
```

---

### Task 9: Conditional authentication routing

**Files:**
- Modify: `config/routes.rb:23`
- Modify: `app/views/devise/shared/_links.slim:13-15`
- Modify: `app/controllers/application_controller.rb` (add `after_sign_out_path_for`)
- Test: `spec/routing/authentication_routes_spec.rb` (create)

**Interfaces:**
- Consumes: `Settings.password_login_enabled?` (Task 1), `Users::OauthHandoffController` (Task 7).
- Produces: `new_user_session_path` → the handoff when the flag is off, the password form when it is on; `destroy_user_session_path` in both.

Routes become conditional:

```ruby
if Settings.password_login_enabled?
  devise_for :users, controllers: {
    invitations: "users/invitations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks",
  }
else
  devise_for :users,
             skip: %i[sessions passwords unlocks registrations invitations],
             controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get "/users/sign_in" => "users/oauth_handoff#new", as: :new_user_session
    match "/users/sign_out" => "users/sessions#destroy",
          as: :destroy_user_session, via: Devise.sign_out_via
  end
end
```

Keeping the route *name* `new_user_session` pointed at the handoff is what makes automatic entry work without touching anything else: Devise's `authenticate_user!` failure path already redirects there and `stored_location_for` already captures the destination, so all 26 controllers and every deep link keep working untouched.

`Devise.sign_out_via` rather than a literal verb: `config/initializers/devise.rb` sets `config.sign_out_via` twice — `:delete` at line 284, then `:get` at line 300 — so the effective value is `:get`, and `app/views/shared/_navigation.html.slim:7` renders sign-out as a plain link. Deriving the verb keeps the manual route correct if that duplication is ever cleaned up.

Invitations are skipped with the password routes because accepting an invitation is a password-setting flow. Role management continues through the existing `resources :users` screens.

`after_sign_out_path_for` returns the handoff with the signed-out marker Task 7 reads, so sign-out shows confirmation instead of bouncing the user back in.

`app/views/devise/shared/_links.slim:13-15` contains a dormant `devise_mapping.omniauthable?` block that activates now the module is enabled. It renders a `link_to` — a GET — which `omniauth-rails_csrf_protection` rejects. Delete the block; the handoff is the only entry point.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/routing/authentication_routes_spec.rb
require "rails_helper"

RSpec.describe "authentication routes", type: :routing do
  around do |example|
    example.run
  ensure
    Rails.application.reload_routes!
  end

  def redraw_with_password_login(enabled)
    allow(Settings).to receive(:password_login_enabled?).and_return(enabled)
    Rails.application.reload_routes!
  end

  context "when password login is disabled" do
    before { redraw_with_password_login(false) }

    it "routes GET /users/sign_in to the handoff" do
      expect(get: "/users/sign_in")
        .to route_to("users/oauth_handoff#new")
    end

    it "does not route the password reset form" do
      expect(get: "/users/password/new").not_to be_routable
    end

    it "does not route the unlock form" do
      expect(get: "/users/unlock/new").not_to be_routable
    end

    it "does not route invitation acceptance" do
      expect(get: "/users/invitation/accept").not_to be_routable
    end

    it "still routes sign out" do
      expect(Devise.sign_out_via => "/users/sign_out")
        .to route_to("users/sessions#destroy")
    end

    it "still routes the OmniAuth callback" do
      expect(get: "/users/auth/entra_id/callback")
        .to route_to("users/omniauth_callbacks#entra_id")
    end
  end

  context "when password login is enabled" do
    before { redraw_with_password_login(true) }

    it "routes GET /users/sign_in to the password form" do
      expect(get: "/users/sign_in").to route_to("users/sessions#new")
    end

    it "routes the password reset form" do
      expect(get: "/users/password/new").to be_routable
    end
  end
end
```

The `ensure` block restoring the real routes matters — `config.order = "random"` (`spec/rails_helper.rb:38`) means a leaked route table breaks an unrelated spec in a way that is painful to track down.

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/routing/authentication_routes_spec.rb`
Expected: FAIL — `/users/password/new` is routable with the flag off

- [ ] **Step 3: Make the routes conditional**

- [ ] **Step 4: Add `after_sign_out_path_for` and remove the dead OmniAuth link**

- [ ] **Step 5: Run the full suite**

Run: `bundle exec rspec && bundle exec rubocop`
Expected: PASS — `password_login_enabled?` still defaults to true, so the feature specs are untouched by this task

- [ ] **Step 6: Commit**

```bash
git add config/routes.rb app/controllers/application_controller.rb app/views/devise/shared/_links.slim spec/routing/authentication_routes_spec.rb
git commit -m "CDPTKAN-1183 Mount password routes only when the flag is on"
```

---

### Task 10: Parameter filtering

**Files:**
- Modify: `config/initializers/filter_parameter_logging.rb`
- Test: `spec/lib/filter_parameter_logging_spec.rb` (create)

Add `:code`, `:state`, `:id_token`, `:access_token`, `:refresh_token`, `:client_secret` alongside the existing `:password`. Without this the authorization code lands in the Rails access log, where it is a replayable credential for its lifetime.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/lib/filter_parameter_logging_spec.rb
require "spec_helper"

RSpec.describe "parameter filtering" do
  it "filters OAuth credentials from logs" do
    expect(Rails.application.config.filter_parameters)
      .to include(:code, :state, :id_token, :access_token, :refresh_token, :client_secret, :password)
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/lib/filter_parameter_logging_spec.rb`
Expected: FAIL — `:code` is absent

- [ ] **Step 3: Add the parameters**

- [ ] **Step 4: Run tests**

Run: `bundle exec rspec spec/lib/filter_parameter_logging_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add config/initializers/filter_parameter_logging.rb spec/lib/filter_parameter_logging_spec.rb
git commit -m "CDPTKAN-1183 Filter OAuth credentials from logs"
```

---

### Task 11: Flip the test environment to OAuth

**Files:**
- Modify: `lib/settings.rb` (change the `password_login_enabled?` default to `false`)
- Modify: `spec/support/features/session_helpers.rb`
- Create: `spec/features/authentication_spec.rb`
- Modify: whichever feature specs assert on the sign-in page
- Test: the whole suite

**Interfaces:**
- Consumes: everything from Tasks 1–10.
- Produces: `Features::SessionHelpers#sign_in(email, _password = nil)` driving OmniAuth test mode; `#create_pq_session`; `#create_admin_session` — all three keep their current names and arities so call sites do not change.

`#create_pq_session` has 44 call sites and `#create_admin_session` 2, and both funnel through `#sign_in`, which has 3 direct callers. Rewriting `#sign_in` is therefore the entire migration: set `OmniAuth.config.test_mode = true`, build a `mock_auth[:entra_id]` hash carrying a stubbed `oid`, `tid`, `aud`, `iss`, email and name, visit the handoff, and follow it through to the callback.

Give each `DbHelpers.users` fixture (`spec/support/db_helpers.rb:36-45`) a deterministic `azure_oid` so feature specs match on `oid` rather than exercising the trust-on-first-use path on every example. Reset `OmniAuth.config.mock_auth` between examples.

`#sign_in` keeps its `password` parameter, defaulted and ignored, so the 3 direct call sites need no edit.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/features/authentication_spec.rb
require "feature_helper"

feature "authentication" do
  scenario "an unauthenticated visitor is taken into the OAuth journey" do
    visit dashboard_path
    expect(page).to have_current_path "/users/sign_in"
    expect(page).to have_button "Sign in"
  end

  scenario "a deep link survives the round trip" do
    # visit a specific PQ, authenticate, land back on that PQ
  end

  scenario "signing out shows confirmation and does not sign the user back in" do
    create_pq_session
    click_link "Sign out"
    expect(page).to have_content "You have been signed out"
    visit dashboard_path
    expect(page).to have_current_path "/users/sign_in"
  end

  scenario "an unknown tenant user is provisioned as a PQ user" do
    # mock_auth with an oid and email no fixture holds
    expect { ... }.to change(User, :count).by(1)
    expect(User.last.roles).to eq User::ROLE_PQ_USER
  end

  scenario "a failed sign in lands on the support page" do
    # mock_auth set to :invalid_credentials
    expect(page).to have_content "contact"
  end

  context "when password login is enabled" do
    scenario "the password form still works" do
      # stub Settings.password_login_enabled? true, reload_routes!, sign in with a password
    end
  end
end
```

The sign-out scenario is the regression test for the bounce — an auto-submitting handoff would silently sign the user back in and make the "Sign out" nav item a lie.

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/features/authentication_spec.rb`
Expected: FAIL — the password form is still mounted

- [ ] **Step 3: Flip the `password_login_enabled?` default to `false`**

One line in `lib/settings.rb`, plus the corresponding example in `spec/lib/settings_spec.rb`. From here the test environment mirrors production.

- [ ] **Step 4: Rewrite `#sign_in` and add fixture `azure_oid`s**

- [ ] **Step 5: Run the full suite and fix the fallout**

Run: `bundle exec rspec`
Expected: PASS. Expect breakage only in specs that assert on the sign-in page itself; fix those in place rather than reaching for the password flag.

- [ ] **Step 6: Run rubocop and brakeman**

Run: `bundle exec rubocop && bundle exec brakeman -q`
Expected: no offenses, no new warnings. Fix any new Brakeman warning rather than adding it to `config/brakeman.ignore`.

- [ ] **Step 7: Commit**

```bash
git add lib/settings.rb spec/lib/settings_spec.rb spec/support/features/session_helpers.rb spec/support/db_helpers.rb spec/features
git commit -m "CDPTKAN-1183 Switch the test suite to the OAuth sign-in path"
```

---

### Task 12: Environment configuration and documentation

**Files:**
- Modify: `config/kubernetes/development/config_map.yaml`, `config/kubernetes/staging/config_map.yaml`, `config/kubernetes/production/config_map.yaml`
- Modify: `.env.sample`
- Modify: `README.md`

Each configmap gains `OAUTH_AZURE_ENABLED: "true"`, `PASSWORD_LOGIN_ENABLED: "false"`, and that environment's `OMNIAUTH_AZURE_TENANT_ID` and `OMNIAUTH_AZURE_CLIENT_ID`. These are public identifiers that appear in the authorize URL, so committing them is fine. `OMNIAUTH_AZURE_CLIENT_SECRET` goes into the `pq-secrets` secret, which is managed outside this repo and referenced by the `secretRef` at `config/kubernetes/development/deployment.yaml:55-56` — it must never be committed.

`.env.sample` gains the three credential variables, empty, plus both flags, with a comment that localhost does not need real credentials because the developer strategy covers it.

- [ ] **Step 1: Update the three configmaps**

- [ ] **Step 2: Update `.env.sample`**

- [ ] **Step 3: Write the README section**

Cover: that authentication is Entra ID via OmniAuth and Devise; that localhost uses the developer strategy and needs no secret; that a developer wanting the real round trip can set the three variables, since the localhost redirect URI is already registered; that `oid` is the identifier and email is only trusted once, on first link; that a returning soft-deleted user is reactivated as `PQUSER`; and how to flip `PASSWORD_LOGIN_ENABLED` to get the password form back, noting it needs a restart because routes are drawn at boot.

- [ ] **Step 4: Verify no secret has been committed**

Run: `git diff --cached | grep -iE "client_secret|OMNIAUTH_AZURE_CLIENT_SECRET=."`
Expected: no output other than the empty `.env.sample` placeholder

- [ ] **Step 5: Commit**

```bash
git add config/kubernetes .env.sample README.md
git commit -m "CDPTKAN-1183 Configure Azure OAuth per environment"
```

---

### Task 13: Restrict user administration to admins

**Separable.** This fixes a pre-existing authorization gap that this feature makes reachable. If it is to ship separately, drop this task and raise it as its own ticket — but do not ship Tasks 1–12 to production without it.

**Files:**
- Modify: `app/controllers/users_controller.rb:2`
- Modify: `app/controllers/admin_controller.rb:2`
- Test: `spec/controllers/users_controller_spec.rb` (create), `spec/controllers/admin_controller_spec.rb` (create)

`UsersController` is gated by `authenticate_user!`, not `authenticate_admin!`, and `user_params` permits `:roles` and `:deleted`. The role select at `app/views/users/edit.html.slim:13` only offers `PQUSER`, so the UI hides this, but the parameter is permitted, so a crafted POST sets `roles` to `PQUSER,ADMIN`. `AdminController#index` is likewise `authenticate_user!` only.

Today reaching it requires an emailed invitation. After auto-provisioning, anyone with an account in the MoJ tenant can sign in, open `/users`, and escalate themselves. `authenticate_admin!` already exists at `app/controllers/application_controller.rb:26` and redirects non-admins to `root_path`.

- [ ] **Step 1: Write the failing test**

```ruby
# spec/controllers/users_controller_spec.rb
require "rails_helper"

RSpec.describe UsersController, type: :controller do
  context "when signed in as a basic PQ user" do
    before { sign_in create(:user) }

    it "redirects away from the user list" do
      get :index
      expect(response).to redirect_to root_path
    end

    it "refuses to grant itself the admin role" do
      user = create(:user)
      patch :update, params: { id: user.id, user: { roles: "PQUSER,ADMIN" } }
      expect(user.reload.roles).to eq "PQUSER"
    end

    it "refuses to undelete a removed user" do
      removed = create(:user, deleted: true)
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
  end
end
```

The escalation example is the one that matters; the other two confirm the gate rather than the hiding.

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/controllers/users_controller_spec.rb`
Expected: FAIL — a basic user reaches `index` and the role update succeeds

- [ ] **Step 3: Swap the before_action in both controllers**

- [ ] **Step 4: Run the full suite**

Run: `bundle exec rspec && bundle exec rubocop && bundle exec brakeman -q`
Expected: PASS. Any feature spec that reached `/users` or `/admin` as a basic user needs `create_admin_session` instead.

- [ ] **Step 5: Commit**

```bash
git add app/controllers/users_controller.rb app/controllers/admin_controller.rb spec/controllers/users_controller_spec.rb spec/controllers/admin_controller_spec.rb
git commit -m "CDPTKAN-1183 Restrict user administration to admins"
```

---

## Manual verification before calling this done

The suite cannot cover the real provider, and three of the agreed behaviours are only convincing when seen. On localhost with the developer strategy:

- [ ] A new identity is provisioned with `roles == "PQUSER"`.
- [ ] Signing out, then back in, reuses the same row — `User.count` does not change.
- [ ] `User.last.deactivate!` in the console, then sign in again: the row is undeleted, not duplicated, and `roles` is back to `PQUSER`.
- [ ] Set `roles` to `"PQUSER,ADMIN"`, `deactivate!`, sign in again: `roles` is `PQUSER`.
- [ ] `/users/password/new` returns 404.
- [ ] No authorization code or token appears in `log/development.log` after a sign-in.

And once credentials are in place in a deployed environment:

- [ ] The real Azure round trip completes, and the `redirect_uri` Azure receives is `https://` — `config.force_ssl = true` plus the ingress's `X-Forwarded-Proto` should produce that, but the gem derives it from the request, so it needs confirming rather than assuming.
