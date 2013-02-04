require 'api_constraints'

Ledger::Application.routes.draw do
  def self.version(version, default=false, &block)
    namespace version, &block
    scope(module: version, &block) if default
  end


  version "v2", true do
    resources :accounts, only: [ :index, :show ] do
      collection do
        get :edit
        put :update
      end
    end
    resources :bank_entries, only: [ :index, :show, :update, :edit ]
    resources :strategies, only: [ :show, :new, :create ]
    resources :searches, only: [ :new, :create ]

    root :to => 'accounts#index'
  end
end
