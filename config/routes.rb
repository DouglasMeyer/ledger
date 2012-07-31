Sledger::Application.routes.draw do
  resources :bank_entries, :only => [ :index, :show ]

  resources :accounts,  :only => [ :index, :new, :create, :show, :update ] do
    member do
      get :distribute
    end
  end
  resources :account_entries, :only => [ :index, :create, :update, :destroy ]

  root :to => 'static#home'
end
