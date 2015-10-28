class AuthenticateFromProvider
  attr_reader :result

  def initialize(auth)
    @auth = auth
  end

  def success?
    @auth["provider"] == "developer" ||
      @auth["provider"] == "google_oauth2" && (
        @auth["info"]["email"] == "douglasyman@gmail.com" ||
        @auth["info"]["email"] == "kmeyer08@gmail.com"
      )
  end

  def result
    @auth["info"]["name"] if success?
  end
end
