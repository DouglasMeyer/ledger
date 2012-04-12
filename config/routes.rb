Sledger::Application.routes.draw do
  resources :ledgers, :only => [ :index, :show ]

  root :to => 'ledgers#index'
end
