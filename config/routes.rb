Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
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

    get 'admin' => 'pages#admin'
    get 'new' => 'pages#react'
    root to: 'pages#angular'
  end

  get "/auth/failure" => "sessions#failure"
  match "/auth/:provider/callback" => "sessions#create", via: [ :get, :post ]
  get "/auth/developer" => "sessions#new" unless Rails.env.production?
  get "/sign_out" => "sessions#destroy"

  post '/api' => 'api#bulk'
end
