class ApplicationController < ActionController::Base
  before_action :authenticate
  before_action :scope_tenant

  private

  def authenticate
    unless session[:auth_user]
      if request.xhr?
        head :unauthorized
        throw :abort
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
    logger.info "schema_search_path = #{schema}"
    ActiveRecord::Base.connection.schema_search_path = schema
  end

  def admin_only
    unless AuthIsAdmin.new(session[:auth_user]).success?
      render status: :unauthorized,
        text: "Only the admin is authorized to be here"
    end
  end
end
