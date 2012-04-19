Sledger::Application.routes.draw do
  resources :ledgers, :only => [ :index, :show ] do
    resources :entries, :only => :index
  end

  root :to => 'ledgers#index'
end
