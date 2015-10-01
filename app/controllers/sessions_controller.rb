class SessionsController < ApplicationController
  skip_before_filter :authenticate

  def create
    auth = request.env['omniauth.auth']
    action = AuthenticateFromProvider.new(auth)
    session[:auth_user] = action.result
    if action.success?
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
