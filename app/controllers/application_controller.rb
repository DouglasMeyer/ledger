class ApplicationController < ActionController::Base
  before_action :authenticate
  around_action :scope_tenant

  private

  def authenticate
    return if session[:auth_user]

    if request.xhr?
      render status: :unauthorized, json: { error: :unauthorized }
    else
      redirect_to "/auth/google_oauth2"
    end
  end

  def scope_tenant(&block)
    ledger = session[:auth_user][:ledger] if session[:auth_user]

    schema = if ledger
      logger.info "TenantLedger.scope #{ledger}"
      TenantLedger.scope(ledger, &block)
    else
      yield
    end
  end

  def admin_only
    unless AuthIsAdmin.new(session[:auth_user]).success?
      render status: :unauthorized,
        plain: "Only the admin is authorized to be here"
    end
  end
end
