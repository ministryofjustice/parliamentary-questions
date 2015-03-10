ParliamentaryQuestions::Application.routes.draw do
  get 'ping' => 'ping#index'

  resources :minister_contacts
  get 'minister_contacts/new/:id' => 'minister_contacts#new', :as => :new_minister_contact_withid

  resources :ogds
  get 'find_ogd' => 'ogds#find'

  resources :press_desks

  resources :press_officers

  resources :progresses

  resources :ministers

  resources :deputy_directors

  resources :divisions

  resources :directorates

  resources :watchlist_members
  resources :actionlist_members

  resources :action_officers

  devise_for :users , :controllers => { :invitations => 'users/invitations' }
  resources :users

  resources :pqs, only: [ :index, :show, :update ]

  resources :trim_links

  get 'trim_links/new/:id' => 'trim_links#new'

  get 'admin' => 'admin#index'

  get 'commission/:id' => 'commission#commission'
  get 'commission_complete/:id' => 'commission#complete'
  get 'commission_reject_manual/:id' => 'manual_reject_commission#reject_manual'
  post 'commission' => 'commission#commission', as: :commission

  get '/', to: 'root#index', as: :root
  get 'dashboard' => 'dashboard#index'
  get 'dashboard/in_progress' => 'dashboard#in_progress'

  get 'search' => 'search#index'

  get 'filter' => 'filter#index'
  get 'filter/:search' => 'filter#index'

  get 'dashboard/search' => 'dashboard#search'
  post 'dashboard/search/:search' => 'dashboard#search'

  get 'dashboard/by_status/:qstatus' => 'dashboard#by_status', as: :dashboard_by_status
  get 'dashboard/in_progress_by_status/:qstatus' => 'dashboard#in_progress_by_status', as: :dashboard_in_progress_by_status
  get 'dashboard/transferred' => 'dashboard#transferred', as: :dashboard_transferred
  get 'dashboard/i_will_write' => 'dashboard#i_will_write', as: :dashboard_iww

  get 'assignment/:uin' => 'assignment#show', as: :assignment
  post 'assignment/:uin' => 'assignment#create'

  get 'watchlist/dashboard' => 'watchlist_dashboard#index'
  get 'watchlist/preview' => 'watchlist_dashboard#preview'
  get 'watchlist/send_emails' => 'watchlist_send_emails#send_emails'

  # TODO I think this is unused code
  get 'find_action_officers' => 'action_officers#find'

  get 'finance/questions' => 'finance#questions'
  post 'finance/confirm' => 'finance#confirm'

  get 'transferred/new' => 'transferred#new'
  post 'transferred/create' => 'transferred#create'

  get 'i_will_write/create' => 'i_will_write#create'

  get 'send_accept_reject_reminder/:id' => 'action_officer_reminder#accept_reject'
  get 'send_draft_reminder/:id' => 'action_officer_reminder#send_draft'

  match 'export/pq.csv' => 'export#csv', via: [:get, :post]
  get 'export' => 'export#index'

  match 'export_pod/pq_pod.csv' => 'export#csv_for_pod', via: [:get, :post]
  get 'export_pod' => 'export#index_for_pod'

  get 'reports/ministers_by_progress' => 'reports#ministers_by_progress'
  get 'reports/press_desk_by_progress' => 'reports#press_desk_by_progress'
  match 'reports/filter_all' => 'reports#filter_all', via: [:get, :post]
  match "*path", to: "application#page_not_found", via: :all

  if Rails.env.production?
    get '401', :to => 'application#unauthorized'
    get '404', :to => 'application#page_not_found'
    get '500', :to => 'application#server_error'
  end
end
