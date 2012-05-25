Sledger::Application.routes.draw do
  resources :bank_entries, :only => :index

  resources :accounts,  :only => [ :index, :new, :create ]
  resources :account_entries, :only => [ :index, :create, :destroy ]

  root :to => 'accounts#index'
end
