class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate

private
  def authenticate
    if (name = ENV['AUTH_NAME']) && (pass = ENV['AUTH_PASSWORD'])
      unless authenticate_with_http_basic { |u, p| u == name && p = pass }
        request_http_basic_authentication
      end
    end
  end

end
