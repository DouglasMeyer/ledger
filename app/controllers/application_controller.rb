class ApplicationController < ActionController::Base
  before_filter :authenticate
  before_filter :scope_tenant

  private

  def authenticate
    unless session[:auth_user]
      if request.xhr?
        head :unauthorized
        false
      else
        redirect_to "/auth/google_oauth2"
      end
    end
  end

  def scope_tenant
    ledger = session[:auth_user][:ledger] if session[:auth_user]

    if ledger
      schema = "#{ledger},public"
    else
      schema = 'public'
    end
    ActiveRecord::Base.connection.schema_search_path = schema
  end
end
