Ledger::Application.routes.draw do
  def self.version(version, default=false, &block)
    namespace version, &block
    root to: redirect("/#{version}") if default
  end


  version "v2" do
    resources :accounts, only: [ :index, :show ] do
      collection do
        get :edit
        put :update
      end
    end
    resources :bank_entries, only: [ :index, :create, :show, :update, :edit ]
    resources :strategies, only: [ :index, :show, :new, :create ]
    resources :bank_imports, only: [ :create ]

    root :to => 'accounts#index'
  end

  version "v3", true do
    resources :accounts, only: [ :index, :show ] do
      collection do
        get :edit
        put :update
      end
    end
    resources :bank_entries, only: [ :index, :create, :show, :update, :edit ]
    resources :strategies, only: [ :index, :show, :new, :create ]
    resources :bank_imports, only: [ :create ]

    root :to => 'accounts#index'
    if Rails.env.production?
      offline = Rack::Offline.configure :cache_interval => 120 do
        cache ActionController::Base.helpers.asset_path("normalize.css")
        cache ActionController::Base.helpers.asset_path("v3.css")
        cache ActionController::Base.helpers.asset_path("v3.js")
        cache ActionController::Base.helpers.asset_path("icomoon.svg")
        cache "/v3"
        cache "/v3/bank_entries"
        network "/api"
      end
      get '/application.manifest' => offline, as: :manifest
    end
  end

  post '/api' => 'api#bulk'
end
