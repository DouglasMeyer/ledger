class ApplicationController < ActionController::Base
  before_action :authenticate

  private

  def authenticate
    return if session[:auth_user]

    if request.xhr?
      head :unauthorized
      false
    else
      redirect_to '/auth/google_oauth2'
    end
  end
end
