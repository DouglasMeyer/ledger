Rails.application.routes.draw do
  def self.version(version, default = false, &block)
    namespace version, &block
    root to: redirect("/#{version}") if default
  end

  version "v3", true do
    resources :accounts, only: :show do
      collection do
        get :edit
        put :update
      end
    end
    resources :bank_entries, only: [ :create, :show, :update, :edit ]
    resources :strategies, only: [ :index, :show, :new, :create ]
    resources :bank_imports, only: [ :create ]

    root to: 'pages#angular'
    offline = Rack::Offline.configure cache: true do
      %w( normalize.css v3.css v3.js icomoon.ttf ).each do |asset|
        cache ActionController::Base.helpers.asset_path(asset)
      end
      cache "/v3"
      network "/api"
    end
    get '/application.manifest' => offline, as: :manifest
  end

  match "/auth/:provider/callback" => "sessions#create", via: [ :get, :post ]
  get "/sign_out" => "sessions#destroy"

  post '/api' => 'api#bulk'
end
