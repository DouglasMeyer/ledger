class ApplicationController < ActionController::Base
  before_filter :authenticate

  private

  def authenticate
    unless session[:auth_user]
      head :unauthorized
      false
    end
  end
end
