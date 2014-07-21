ParliamentaryQuestions::Application.routes.draw do


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

  devise_for :users

  resources :users

  resources :pqs  
  resources :trim_links

  get 'trim_links/new/:id' => 'trim_links#new'

  get 'admin' => 'admin#index'

  get 'commission/:id' => 'commission#commission'
  get 'commission_reject_manual/:id' => 'manual_reject_commission#reject_manual'
  post 'assign/:id' => 'commission#assign'
  get 'answering/:id' => 'answering#index'
  post 'answering/:id' => 'answering#answer'

  get '/', to: 'root#index', as: :root
  get 'dashboard' => 'dashboard#index'
  get 'dashboard/in_progress' => 'dashboard#in_progress'


  get 'search' => 'search#index'

  get 'filter' => 'filter#index'
  get 'filter/:search' => 'filter#index'
  get 'dashboard/search' => 'dashboard#search'
  post 'dashboard/search/:search' => 'dashboard#search'


  get 'dashboard/by_status/:qstatus' => 'dashboard#by_status'
  get 'dashboard/in_progress_by_status/:qstatus' => 'dashboard#in_progress_by_status'
  get 'dashboard/transferred' => 'dashboard#transferred'
  get 'dashboard/i_will_write' => 'dashboard#i_will_write'
  
  get 'assignment/:uin' => 'assignment#index'
  post 'assignment/:uin' => 'assignment#action'

  get 'watchlist/dashboard' => 'watchlist_dashboard#index'
  get 'watchlist/preview' => 'watchlist_dashboard#preview'
  get 'watchlist/send_emails' => 'watchlist_send_emails#send_emails'
  get 'find_action_officers' => 'action_officers#find'

  get 'members/by_name' => 'members#by_name'

  get 'import/question' => 'import#question'
  get 'import/questions' => 'import#questions'
  get 'import/questions_force_update' => 'import#questions_force_update'
  get 'import/questions_no_log' => 'import#questions_no_log'
  get 'import/questions_no_log' => 'import#questions_no_log'
  get 'import/questions_async' => 'import#questions_async'

  get 'import/logs' => 'import#logs'

  get 'finance/questions' => 'finance#questions'
  post 'finance/confirm' => 'finance#confirm'

  get 'transferred/new' => 'transferred#new'
  post 'transferred/create' => 'transferred#create'

  get 'i_will_write/create' => 'i_will_write#create'

  get 'assign_minister/:id' => 'pqs#assign_minister'
  patch 'assign_minister/:id' => 'pqs#assign_minister'

  get 'assign_answering_minister/:id' => 'pqs#assign_answering_minister'
  patch 'assign_answering_minister/:id' => 'pqs#assign_answering_minister'

  get 'send_accept_reject_reminder/:id' => 'action_officer_reminder#accept_reject'
  get 'send_draft_reminder/:id' => 'action_officer_reminder#send_draft'

  patch 'set_internal_deadline/:id' => 'pqs#set_internal_deadline'

  match 'export/pq.csv' => 'export#csv', via: [:get, :post]
  get 'export' => 'export#index'
end
