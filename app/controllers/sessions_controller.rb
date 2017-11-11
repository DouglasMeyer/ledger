class SessionsController < ApplicationController
  skip_before_action :authenticate
  skip_around_action :scope_tenant

  def new
    strategy = request.env['omniauth.strategy']
    @url = strategy.callback_url
    @ledgers = TenantLedger.all
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
      render locals: { location: root_path, user: user }
    else
      render html: <<-END.html_safe
        <h3>You tried to signed-in using "#{auth.info.email}", and that isn't setup in Ledger.</h3>
        <p><a href="/sign_out">Sign-out</a> to try another account (you may have to go to <a href="http://www.google.com" target="_blank">google</a> and sign-out).</p>
        <pre style="display:none">#{auth.to_yaml}</pre>
      END
    end
  end

  def destroy
    session[:auth_user] = nil
    redirect_to root_path
  end
end
