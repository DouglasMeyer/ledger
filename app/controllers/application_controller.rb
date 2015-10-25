class ApplicationController < ActionController::Base
  before_filter :authenticate

  private

  def authenticate
    unless session[:auth_user]
      if request.xhr?
        head :unauthorized
        false
      else
        redirect_to '/auth/google_oauth2'
      end
    end
  end
end
