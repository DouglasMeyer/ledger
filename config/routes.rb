Sledger::Application.routes.draw do
  resources :bank_entries, :only => :index

  resources :accounts,  :only => [ :index, :new, :create, :show ] do
    member do
      get :distribute
    end
  end
  resources :account_entries, :only => [ :index, :create, :update, :destroy ]

  root :to => 'accounts#index'
end
