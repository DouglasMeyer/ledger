Ledger::Application.routes.draw do
  def self.version(version, default=false, &block)
    namespace version, &block
    scope(module: version, &block) if default
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
  end

  post '/api' => 'api#bulk'
end
