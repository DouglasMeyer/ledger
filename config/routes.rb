require 'api_constraints'

Sledger::Application.routes.draw do
  def self.version(version, default=false, &block)
    namespace "v#{version}", &block
    scope(module: "v#{version}", &block) if default
  end


  version 2 do
    resources :accounts, :only => :index
    resources :bank_entries, :only => [ :index, :update, :edit ]

    root :to => 'accounts#index'
  end

  version 1, true do
    namespace :api, :defaults => { :format => 'json' } do
      scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => :true) do
        resources :accounts, :only => [ :index, :create, :update, :destroy ]
        resources :bank_entries, :only => [ :index, :show ]
        resources :account_entries, :only => [ :index, :create, :update, :destroy ]
      end
    end

    root :to => 'static#home'
  end
end
