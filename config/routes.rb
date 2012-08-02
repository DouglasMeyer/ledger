require 'api_constraints'

Sledger::Application.routes.draw do
  namespace :api, :defaults => { :format => 'json' } do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => :true) do
      resources :accounts, :only => [ :index, :create, :update ]
      resources :bank_entries, :only => [ :index, :show ]
      resources :account_entries, :only => [ :index, :create, :update, :destroy ]
    end
  end

  root :to => 'static#home'
end
