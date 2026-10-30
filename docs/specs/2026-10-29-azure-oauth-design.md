# Azure Entra ID OAuth sign-in for PQ Tracker — design

Date: 2026-10-29
Branch: `CDPTKAN-1183-add-oauth`
Status: design agreed, implementation in progress

## Amendment, 2026-10-30 — gem and claim locations

Agreed with the repository owner during implementation:

- The strategy gem is **`omniauth-entra-id` 3.1.1**, not
  `omniauth-azure-activedirectory-v2`. The latter resolved to 2.4.0, which its
  maintainers have formally deprecated in favour of `omniauth-entra-id` and
  which warns on every load. The strategy name is therefore `entra_id`
  throughout — provider symbol, route, callback action, configmaps — and the
  references below have been renamed accordingly.
- Verified against the installed strategy source, correcting what this document
  assumed: `oid`, `tid`, `aud`, `iss`, `email`, `upn`, `preferred_username` and
  `name` all sit in `extra.raw_info` (the merged id_token and access_token
  claims). `info.email` is `raw_info['email']` alone and performs no fallback,
  so the `email` → `preferred_username` chain must be read from `raw_info` by
  our own code.
- The gem does **not** verify the id_token signature — both decodes are
  `JWT.decode(token, nil, false)`, relying on TLS from the token endpoint. It
  *does* verify `aud`, `iss`, `exp` and `nbf` via `JWT::Claims.verify_payload!`.
  It does **not** verify `tid`. Designer decision 5's own `tid`/`aud`/`iss`
  validation is retained as defence in depth, and is the only `tid` check.
- Registered with `ignore_tid: true` so the gem's `uid` is the bare `oid` that
  `azure_oid` stores, rather than its default `tid + oid` concatenation.

## Intent

PQ Tracker authenticates users with Devise email/password, provisioned by
`devise_invitable`. This replaces that with OAuth 2.0 Authorization Code flow
against Microsoft Entra ID (Azure AD), using OmniAuth through Devise's
`omniauthable` module, so PQ stops holding credentials and inherits the MoJ
tenant's authentication controls (MFA, conditional access, joiner/leaver
process).

The existing email/password code stays in the repository, switched off by an
environment-driven feature flag, so it can be turned back on per environment
without shipping new code.

## Goals

- All users enter an OAuth journey automatically. No password form is presented.
- Identity is pinned to the Entra immutable object ID (`oid`), not email.
- New users are provisioned automatically on first successful sign-in with the
  basic `PQUSER` role.
- Each environment (localhost, development, staging, production) uses its own
  Azure credentials.
- Any failure lands on a PQ-owned error page, in the app's own layout and CSS,
  directing the user to support.
- The email/password path is preserved in code and re-enablable by flag.

## Non-goals

- No role or group mapping from Entra. Roles stay PQ-managed (`PQUSER`,
  `ADMIN`).
- No Microsoft Graph access. Only the OIDC claims needed to identify a user.
- No single logout across MoJ applications. Signing out ends the PQ session only.
- No second identity provider. One provider, one tenant.
- No change to what PQ does once a user is signed in, beyond the authorization
  fix in "Discovered issue" below.
- **No change to the token-based action-officer flows.** `AssignmentController`
  runs `before_action AoTokenFilter`, which validates a signed token from an
  emailed link; `ProposalsController` has its own private `authenticate_user`
  (no bang, unrelated to Devise). Action officers are external recipients
  without PQ accounts and without tenant identities, so these paths must stay
  outside Devise authentication entirely. A builder tidying up "controllers
  missing authentication" would break the commissioning journey.

## Anti-goals

Things that would make this a failure even if it technically worked:

- A live password endpoint in production while the flag is off.
- Email ever being sufficient to assume an existing account after that account
  has been pinned to an `oid`.
- A removed user silently acquiring a second account, or silently recovering
  elevated privileges.
- Provider-supplied error text rendered into a PQ page.
- An authorization code, token, or client secret written to logs.
- The OmniAuth developer strategy reachable in any deployed environment.

## Decisions taken by the product owner

| Decision | Choice |
| --- | --- |
| Flow | OAuth 2.0 Authorization Code, via OmniAuth + Devise |
| Entry | Users are entered into the OAuth journey automatically; no form |
| Failure | PQ-owned error page, app layout and CSS, "contact support" |
| Password login | Code retained, disabled by feature flag |
| Identifier | Entra per-tenant object ID (`oid`) |
| First link | Trust-on-first-use: match by email once, store `oid`, never trust email for that account again |
| Provisioning | Auto-provision unknown users with role `PQUSER` |
| Access gate | Any user successfully authenticated against the tenant. No domain allowlist, no group check |
| Returning soft-deleted user | Undelete the same row (not a duplicate) |
| Returning user's roles | Reset to `PQUSER` to prevent accidental privilege escalation |
| Sign-out | PQ session only; Entra session untouched |
| Handoff after sign-out or timeout | Manual button, no auto-submit. Auto-submit applies to fresh arrivals only |
| Profile sync | Name and email refreshed from Entra on every sign-in |
| Azure registrations | Already exist for all environments including `http://localhost:3000` |
| Local development | OmniAuth developer strategy (no Azure round-trip, no secret distributed) |
| Test suite | Mirrors production: OAuth on, password off; `sign_in` helper rewritten to drive OmniAuth test mode |
| Password routes when flag off | Not mounted at all — they 404 |

## Decisions taken by the designer

Called out so they can be checked rather than assumed agreed.

1. **Handoff is an interstitial, not a redirect.** `omniauth-rails_csrf_protection`
   requires the request phase to be a POST carrying a valid authenticity token
   (this is the fix for CVE-2015-9284). A plain `redirect_to
   "/users/auth/entra_id"` is therefore rejected. "Automatic"
   means a PQ page that immediately submits a POST form, with a visible button
   as the no-JS fallback.
2. **One generic error page for every failure mode.** Reasons are logged
   server-side and never rendered. Echoing provider-supplied `error_description`
   into a PQ-branded page is a reflected-content vector.
3. **Feature flags are ENV-driven, read through `Settings`.** PQ already
   configures everything through ENV plus a flat `config/settings.yml`; it has
   no feature-flag mechanism and `lib/settings.rb` has no per-environment
   sections. Porting the sibling app's `FeatureSet` would mean also porting
   nested per-host settings and extending `HostEnv`. ENV flags per k8s configmap
   match how PQ already works.
4. **A dedicated `azure_oid` column, not a generic `provider`/`uid` pair.** One
   provider, named explicitly. If a second IdP is ever added, migrate then.
5. **`tid`, `aud` and `iss` are all validated in the callback**, in addition to
   scoping the endpoints to a single tenant via the gem's `tenant_id`. Tenant
   membership is the only access gate, so it gets belt-and-braces treatment.
6. **A successful OAuth sign-in clears any Devise lock.** `lockable` counts
   failed *password* attempts. With password login off those counts cannot grow,
   and the unlock route is not mounted, so an account locked before cutover
   would otherwise be permanently stranded with no self-service route out.
   Entra having authenticated the user supersedes a stale password-attempt lock.
7. **An email sync collision does not block sign-in.** If Entra returns an email
   already held by a different PQ row, the `oid`-matched user is signed in, the
   email sync is skipped, and a warning is logged for an admin to resolve.
   The `oid` is proof of identity; email is a display and notification field.
   Refusing a provably legitimate user over a data collision is the worse
   outcome.
8. **An email match onto a row that already holds a *different* `azure_oid` is
   refused.** That is the one case where trust-on-first-use could be abused —
   an address re-assigned in the tenant to a different human. The account is
   already pinned, so the new identity is rejected and logged.

## Constraints

From the codebase:

- Rails 8.1.3, Ruby 4.0.3, Devise `~> 5.0`, `devise_invitable ~> 2.0`.
- Views are Slim. Error pages live in `app/views/errors/*.html.slim`, rendered
  by `ErrorsController` through `config.exceptions_app = routes`, routed at
  `/404` and `/500`. Support address `PQsupport-gg@justice.gov.uk` appears
  literally in `app/views/errors/not_found.html.slim`; `Settings.mail_tech_support`
  holds the same value.
- `devise_for :users, controllers: { invitations: "users/invitations", sessions: "users/sessions" }`.
  `Users::SessionsController#create` deliberately rotates the session, preserving
  `_csrf_token` — Devise does not reset the session on sign-in by itself.
- `app/views/devise/shared/_links.slim` already contains a dormant
  `devise_mapping.omniauthable?` block that will activate once the module is
  enabled. It renders a `link_to` (GET), which `omniauth-rails_csrf_protection`
  will reject, so it must be fixed or removed.
- `User` has `ROLES = %w[PQUSER ADMIN]` stored as a comma-separated string,
  `SoftDeletion` (`deleted` boolean, `activate!`/`deactivate!`, `active`/
  `inactive` scopes), `active_for_authentication?` returning `!deleted? && super`,
  and an `after_initialize :set_defaults` that sets `roles ||= PQUSER`.
- `:validatable` requires a password on create, so auto-provisioned users need a
  random unusable one.
- CSP: `script_src :self, :unsafe_eval, googletagmanager`, with a nonce
  generator configured and `nonce_directives = %w[script-src]`. An inline
  auto-submit script must use `javascript_tag nonce: true`. `form-action` is
  unset and does not inherit from `default-src`, and the interstitial posts
  same-origin anyway, so no CSP change is needed.
- `config.force_ssl = true` in production; the ingress sets `X-Forwarded-Proto`.
  The gem derives `redirect_uri` from the request, so this must be confirmed to
  produce `https://` in deployed environments.
- `config.filter_parameters += [:password]` only. Needs widening.
- Deployment is raw k8s manifests under `config/kubernetes/{development,staging,production}/`,
  with `envFrom` a committed `config_map.yaml` plus a `pq-secrets` secretRef
  managed outside the repo.
- Specs are RSpec + Capybara (headless Chrome). `Features::SessionHelpers#sign_in`
  fills in the password form; it is the single choke point for all feature-spec
  authentication.

From OAuth/OmniAuth:

- OmniAuth 2.x only accepts POST for the request phase.
- `omniauth-oauth2` generates and verifies the `state` parameter in the session;
  the check happens in middleware, before the callback controller runs.
- Reference app's resolved versions: `omniauth 2.1.4`,
  `omniauth-entra-id 1.0.0`, `omniauth-oauth2 1.9.0`,
  `omniauth-rails_csrf_protection 2.0.1`.

## Design

### Gems

```ruby
gem "omniauth-entra-id"
gem "omniauth-rails_csrf_protection"
```

Let Bundler resolve versions against Rails 8.1 / Ruby 4.0 rather than copying
the sibling app's pins. `omniauth-rails_csrf_protection` is not optional.

### Configuration

Three values per environment:

| Variable | Sensitivity | Where it lives |
| --- | --- | --- |
| `OMNIAUTH_AZURE_TENANT_ID` | public identifier | `config_map.yaml` per environment |
| `OMNIAUTH_AZURE_CLIENT_ID` | public identifier | `config_map.yaml` per environment |
| `OMNIAUTH_AZURE_CLIENT_SECRET` | secret | `pq-secrets`, never in the repo |

Two flags, also per environment:

| Flag | development | staging | production | test | localhost |
| --- | --- | --- | --- | --- | --- |
| `OAUTH_AZURE_ENABLED` | true | true | true | true | true |
| `PASSWORD_LOGIN_ENABLED` | false | false | false | false | false |

Both are read through new `Settings` accessors following the existing style in
`lib/settings.rb`, so nothing reads `ENV` directly at call sites. In production,
`OAUTH_AZURE_ENABLED` being true with any of the three credentials missing must
raise at boot rather than fail at first sign-in, matching the existing
`Settings::PqRestApi.from_env` pattern.

`.env.sample` gains the three variables (empty) and both flags, with a comment
that localhost does not need real credentials because the developer strategy
covers it.

### Devise and provider registration

`config/initializers/devise.rb`:

- `config.omniauth :entra_id, tenant_id:, client_id:,
  client_secret:, scope: "openid profile email"` — registered only when
  `Settings.oauth_azure_enabled?`.
- `config.omniauth :developer` — registered only when `Rails.env.development?`.
  Never in test (test uses OmniAuth test mode), never in any deployed
  environment. This guard is the single thing preventing a trivially forgeable
  identity in production, so it is asserted by a spec.
- `OmniAuth.config.failure_raise_out_environments = []` so development routes
  failures to the error page like everywhere else.

`User`:

```ruby
devise :invitable, :database_authenticatable, :recoverable, :rememberable,
       :trackable, :lockable, :timeoutable, :validatable, :omniauthable,
       omniauth_providers: ...,
       validate_on_invite: true
```

`omniauth_providers` is the registered provider list, so it includes
`:developer` in development only.

### Migration

`azure_oid` on `users`: string, nullable, with a unique index. Nullable because
existing rows have no `oid` until their owner first signs in; unique so the
trust-on-first-use link cannot be claimed twice even under a race.

### Routing

Routes are mounted conditionally so that with `PASSWORD_LOGIN_ENABLED` false
there is no password endpoint at all:

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

Note that `config/initializers/devise.rb` sets `config.sign_out_via` **twice** —
`:delete` at line 284 (the generated default) and `:get` at line 300. The later
assignment wins, so sign-out is currently a GET, and
`app/views/shared/_navigation.html.slim` renders it as a plain link. Deriving
the verb from `Devise.sign_out_via` rather than hardcoding it keeps the manual
route honest if that duplication is ever cleaned up.

Keeping the route *name* `new_user_session` pointed at the handoff is what makes
"automatic" work without touching anything else: Devise's existing
`authenticate_user!` failure path already redirects there, and `stored_location_for`
already captures the original destination, so deep links survive the round trip.

Invitations are skipped with the password routes because accepting an invitation
is a password-setting flow. Role management continues through the existing
`resources :users` admin screens.

### The handoff

`Users::OauthHandoffController#new` renders a minimal Slim page in the standard
application layout, containing a `button_to` targeting
`omniauth_authorize_path(:user, :entra_id)` with `method: :post`.
The button is the no-JS and assistive-technology path and must carry sensible
visible text rather than being hidden.

The page has three modes, differing only in copy and in whether it submits
itself:

| Arriving from | Auto-submits | Heading |
| --- | --- | --- |
| A fresh request to any PQ page | yes | "Signing you in…" |
| An explicit sign-out | no | "You have been signed out" |
| A session timeout | no | "Your session has expired" |

Auto-submit is an inline `javascript_tag nonce: true` that submits the form on
load, rendered only in the first mode. Without this split, sign-out and
`config.timeout_in` have no observable effect: the Entra session outlives the
PQ one, so an auto-submitting handoff hands the user straight back in. Clicking
the button after a sign-out or timeout still reuses the live Entra session, so
it costs one click rather than a credential re-entry.

Detecting the modes:

- Timeout: Devise's `FailureApp` already sets `flash[:timedout]` when the Warden
  message is `:timeout`. Read that.
- Sign-out: override `after_sign_out_path_for` to carry a marker to the handoff.
  A flash is tidier than a query parameter, though a parameter is acceptable
  since the only thing it can do is suppress auto-submit, which is cosmetic.

The fresh-arrival copy matters more than it looks: it is on screen for however
long Azure takes, so it needs to read as progress rather than as a broken page.

### The callback

`Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController`, with
`skip_before_action :set_paper_trail_whodunnit` to match `Users::SessionsController`.

Order of operations:

1. Read `request.env["omniauth.auth"]`. `state` has already been verified by
   middleware.
2. Validate claims: `tid` equals the configured tenant, `aud` equals the
   configured client ID, `iss` is the expected issuer for that tenant. Any
   mismatch is a hard refusal.
3. Require a non-blank `oid`. Refuse if absent.
4. Resolve the user (below), inside a transaction.
5. Capture `stored_location_for(:user)` **before** `reset_session`, then
   `reset_session` and `sign_in_and_redirect`. The explicit reset mirrors what
   `Users::SessionsController#create` does for passwords; Devise does not do it
   for us. It must happen in the controller, after middleware has checked
   `state`, never before.

Resolution, with soft-deleted rows included in every lookup:

1. `User.find_by(azure_oid: oid)` — if found, this is the user. Identity settled.
2. Otherwise `User.find_by("lower(email) = ?", email.downcase)`:
   - if that row already holds a different `azure_oid`, **refuse** (anti-goal 2,
     designer decision 8);
   - otherwise write `azure_oid`. This is the one and only time email is
     trusted for this account.
3. Otherwise create: `azure_oid`, `email`, `name`, `roles: PQUSER`,
   `password: Devise.friendly_token(64)`.

Then, for an existing row:

- if `deleted?`, call `activate!` **and** set `roles` to `PQUSER` — a returning
  removed user comes back as a basic user regardless of what they were;
- clear any `lockable` lock (designer decision 6);
- sync `name` and `email` from Entra, skipping the email write and logging a
  warning if it collides with another row (designer decision 7).

Name falls back to the email local part if Entra sends none, because `User`
validates `name` presence. Email falls back to `preferred_username`; if neither
is present and the row is being created, refuse — `:validatable` requires an
email and PQ sends notifications to it.

Every refusal logs the reason and the `oid` through `LogStuff`, and renders the
error page. `#failure` is overridden to route OmniAuth's own failures
(`invalid_credentials`, `csrf_detected`, `access_denied`, timeouts) to the same
place.

### The error page

A new action on the existing `ErrorsController`, a new Slim view beside the
other two, and a named route alongside `/404` and `/500`. It follows the
structure of `not_found.html.slim`: `govuk-width-container`, `govuk-heading-xl`,
`govuk-body` paragraphs, and a `mailto:` to `Settings.mail_tech_support`. It
responds 403. It says that sign-in could not be completed and to contact
support; it carries no provider text, no claim values, and no retry loop back
into the handoff that could spin.

### Sign-out

`Users::SessionsController#destroy` clears the PQ session and
`after_sign_out_path_for` sends the user to the handoff in its signed-out mode,
so they see confirmation rather than being bounced back in. The Entra session
persists by design, so one click returns them without re-entering credentials.
`destroy_user_session_path` in `app/views/shared/_navigation.html.slim` stays as
it is.

`config.timeout_in` keeps working for the same reason: a 60-minute idle session
lands on the handoff in expired mode and waits for a click, so an unattended
screen does not silently resume.

### Logging

`config/initializers/filter_parameter_logging.rb` gains `:code`, `:state`,
`:id_token`, `:access_token`, `:refresh_token`, `:client_secret` alongside the
existing `:password`. Without this the authorization code lands in the Rails
access log, where it is a replayable credential for its short lifetime.

### Local development

`OAUTH_AZURE_ENABLED=true`, `PASSWORD_LOGIN_ENABLED=false`, no Azure
credentials needed. The developer strategy gives a local form that produces a
fake `oid` and email, exercising the full callback path — claim validation,
resolution, provisioning, sign-in — without a secret on any laptop. Developer
`oid`s are prefixed (e.g. `dev-`) so they can never collide with a real Entra
`oid`. The localhost redirect URI is registered in Azure, so a developer who
needs to exercise the real round trip can set the three variables and will get
the real provider instead.

README gains a section covering this, and the claim-validation behaviour, in
the style of the sibling app's.

### Testing

`Features::SessionHelpers#sign_in` is rewritten to drive OmniAuth test mode:
`OmniAuth.config.test_mode = true` with a `mock_auth` hash carrying a stubbed
`oid`, `tid`, `aud`, `iss`, email and name, then visit the handoff and follow
through to the callback. Because it is the single choke point, the ~20 feature
specs change only where they assert on the sign-in page itself.

New coverage:

- callback specs: known `oid`; email link on first use; email match onto a row
  with a different `oid` (refused); unknown user auto-provisioned as `PQUSER`;
  soft-deleted user undeleted and demoted; `tid` mismatch refused; `aud`
  mismatch refused; missing `oid` refused; locked account cleared and signed in;
  email collision signs in and logs;
- handoff specs: renders a POST form; GET to the authorize path is rejected;
  auto-submits on fresh arrival; does **not** auto-submit after sign-out or when
  `flash[:timedout]` is set;
- sign-out spec: after signing out, the user is on the handoff, is not signed in,
  and the page contains no auto-submit script — this is the regression test for
  the bounce;
- routing specs: with the flag off, `/users/sign_in` is the handoff and
  `/users/password/new` does not route; with it on, both behave as today;
- an initializer spec asserting `:developer` is not among `User.omniauth_providers`
  outside development;
- a spec that session identifiers change across sign-in (fixation);
- one spec with `PASSWORD_LOGIN_ENABLED` true proving the password path still works.

## Discovered issue — needs a decision

While tracing what an auto-provisioned `PQUSER` can reach, this turned up:

- `UsersController` (`index`, `edit`, `show`, `update`) is gated by
  `authenticate_user!` only, not `authenticate_admin!`.
- `user_params` permits `:roles` and `:deleted`.
- `app/views/users/edit.html.slim` offers only `PQUSER` in the role select, so
  the UI hides this, but the parameter is permitted, so a crafted POST can set
  `roles` to `PQUSER,ADMIN`.
- `AdminController#index` is likewise `authenticate_user!` only.

This is pre-existing and not caused by this work. What this work changes is who
can reach it. Today an attacker needs an emailed invitation. After
auto-provisioning, anyone with an account in the MoJ tenant can sign in, open
`/users`, and escalate themselves to `ADMIN`. The tenant is large.

Recommendation: add `before_action :authenticate_admin!` to `UsersController`
and `AdminController` within this change, with specs, because this change is
what makes the exposure reachable. Note that `authenticate_admin!` as written
redirects non-admins to `root_path` rather than erroring, which is fine here.

Related consequence of the agreed demote-on-return rule: with the role select
offering only `PQUSER`, there is no UI path to grant `ADMIN` at all. Re-granting
it after a user is demoted on return requires console or a rake task. Worth
knowing; not blocking.

## What is left to the builder

- Exact gem versions, resolved by Bundler.
- Verifying the installed gem's auth-hash shape before relying on it —
  specifically where `oid`, `tid`, `aud`, `iss`, `email`/`preferred_username`
  and `name` actually sit (`uid`, `info`, `extra.raw_info`), and whether the
  gem verifies the `id_token` signature or relies on having received it over
  TLS from the token endpoint. The claim validation above is written against
  the expected shape and must be adjusted to the real one.
- Confirming `redirect_uri` resolves to `https://` in deployed environments
  given `force_ssl` and the ingress's `X-Forwarded-Proto`.
- Naming: controller, route, flag and column names above are reasonable but not
  sacred.
- Copy for the handoff page and the error page, following existing tone.
- Whether `Settings` gains boolean accessors or a small flag object.
- Ordering of the work, and whether the authorization fix ships in the same PR
  or a separate one.

## Verification before this is called done

- Full RSpec suite green, including the rewritten feature specs.
- Rubocop and Brakeman clean (`config/brakeman.ignore` exists; new warnings
  should be fixed, not ignored).
- Manual check on localhost via the developer strategy: new user provisioned as
  `PQUSER`; sign out and back in reuses the same row; soft-delete the row, sign
  in again, confirm it is undeleted and demoted rather than duplicated.
- Confirmed that with the flag off, `/users/sign_in` shows the handoff and
  `/users/password/new` 404s.
- Manual check that signing out lands on a confirmation page and stays signed
  out until the button is clicked.
- Confirmed no authorization code appears in `log/development.log` after a
  sign-in.
