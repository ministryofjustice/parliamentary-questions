ParliamentaryQuestions::Application.routes.draw do
  get "ping"               => "ping#index"
  get "deploy_info"        => "ping#deploy_info"
  get "healthcheck"        => "health_check#index"

  resources :minister_contacts
  get "minister_contacts/new/:id" => "minister_contacts#new", :as => :new_minister_contact_withid

  resources :ogds
  get "find_ogd" => "ogds#find"

  resources :archives, only: %i[new create]
  resources :press_desks
  resources :press_officers
  resources :progresses
  resources :ministers
  resources :deputy_directors
  resources :divisions
  resources :directorates
  resources :early_bird_members
  resources :action_officers

  # Drawn conditionally so that with PASSWORD_LOGIN_ENABLED off there is no
  # password endpoint at all — the routes 404 rather than merely being hidden.
  # Note this is read at boot, so changing the flag needs a restart.
  if Settings.password_login_enabled?
    devise_for :users, controllers: {
      invitations: "users/invitations",
      sessions: "users/sessions",
      omniauth_callbacks: "users/omniauth_callbacks",
    }

    # The flags are independent, so leaving the password form mounted must not
    # take the OAuth journey away with it.
    devise_scope :user do
      get "/users/oauth_handoff" => "users/oauth_handoff#new"
    end
  else
    # Invitations go with the password routes: accepting an invitation is a
    # password-setting flow. Role management continues through the existing
    # `resources :users` screens below.
    devise_for :users,
               skip: %i[sessions passwords unlocks registrations invitations],
               controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

    devise_scope :user do
      # Keeping the NAME new_user_session is what makes automatic entry work
      # without touching anything else: Devise's authenticate_user! failure
      # path already redirects here and stored_location_for already captures
      # the destination, so every controller and deep link keeps working.
      # This is also the only path to the handoff — one way into a page that
      # submits itself.
      get "/users/sign_in" => "users/oauth_handoff#new", as: :new_user_session

      # Devise.sign_out_via rather than a literal verb: the Devise initializer
      # sets config.sign_out_via twice, :delete and then :get, so the effective
      # value is :get and _navigation.html.slim renders sign-out as a plain
      # link. Deriving it keeps this route correct if that is ever cleaned up.
      match "/users/sign_out" => "users/sessions#destroy",
            as: :destroy_user_session, via: Devise.sign_out_via
    end
  end

  resources :users

  resources :pqs, only: %i[index show update] do
    resource :proposal, only: %i[new create]
  end

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  get "admin" => "admin#index"

  get "commission/:id"               => "commission#commission"
  get "commission_complete/:id"      => "commission#complete"
  get "commission_reject_manual/:id" => "manual_reject_commission#reject_manual"
  post "commission"                  => "commission#commission", as: :commission

  post "quick_action_edit_dates" => "quick_action#dates"
  post "quick_action_draft_reminders/draft_reminders" => "quick_action#draft_reminders"

  get "/", to: "root#index", as: :root
  get "dashboard"             => "dashboard#index"
  get "dashboard/in_progress" => "dashboard#in_progress"
  get "dashboard/backlog"     => "dashboard#backlog"
  get "dashboard/unassigned"  => "dashboard#unassigned"

  get "search" => "search#index"

  get "filter"         => "filter#index"
  get "filter/:search" => "filter#index"

  get "dashboard/search"          => "dashboard#search"
  post "dashboard/search/:search" => "dashboard#search"

  get "dashboard/by_status/:qstatus"             => "dashboard#by_status", as: :dashboard_by_status
  get "dashboard/in_progress_by_status/:qstatus" => "dashboard#in_progress_by_status", as: :dashboard_in_progress_by_status
  get "dashboard/transferred"                    => "dashboard#transferred", as: :dashboard_transferred

  get "assignment/:uin"  => "assignment#show", as: :assignment
  post "assignment/:uin" => "assignment#create"

  get "early_bird/dashboard"   => "early_bird_dashboard#index"
  get "early_bird/preview"     => "early_bird_dashboard#preview"
  get "early_bird/send_emails" => "early_bird_send_emails#send_emails"

  get "find_action_officers" => "action_officers#find"

  get "transferred/new"     => "transferred#new"
  post "transferred/create" => "transferred#create"

  get "early_bird_organiser/new" => "early_bird_organiser#new"
  post "early_bird_organiser/create" => "early_bird_organiser#create"

  get "send_accept_reject_reminder/:id" => "action_officer_reminder#accept_reject"
  get "send_draft_reminder/:id"         => "action_officer_reminder#send_draft"

  match "export/pq.csv" => "export#csv", via: %i[get post]
  get "export"          => "export#index"

  match "export/csv_quick.csv" => "export#csv_quick", via: %i[get post]
  get "export"                 => "export#index"

  get "/accessibility" => "pages#accessibility"

  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unprocessable_content"
  get "/500", to: "errors#internal_error"
  get "/sign_in_failed", to: "errors#sign_in_failed"
end
