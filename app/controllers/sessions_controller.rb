class SessionsController < ApplicationController
  skip_before_filter :authenticate, :scope_tenant

  def new
    strategy = request.env['omniauth.strategy']
    @url = strategy.callback_url
    schemas = ActiveRecord::Base.connection.query("SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'").flatten
    @ledgers = schemas - %w( information_schema public )
  end

  def create
    auth = request.env['omniauth.auth']
    action = AuthenticateFromProvider.new(auth)
    if action.success?
      user = action.result
      session[:auth_user] = {
        provider: user.provider,
        email: user.email,
        ledger: user.ledger
      }
      render locals: { location: root_path, auth_user: action.result }
    else
      yaml = auth.to_yaml
      render text: "<pre>#{yaml}</pre>"
    end
  end

  def destroy
    session[:auth_user] = nil
    redirect_to root_path
  end
end
