class AuthIsAdmin
  def initialize(auth)
    @auth = auth
  end

  def success?
    return false unless admin_auth.present?
    admin_auth.all? { |key, value| @auth[key.to_sym] == value }
  end

  private

  def admin_auth
    JSON.parse(ENV['ADMIN_AUTH']) if ENV['ADMIN_AUTH']
  end
end
