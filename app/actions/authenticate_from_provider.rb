class AuthenticateFromProvider
  def initialize(auth)
    @auth = auth
  end

  def success?
    result.present?
  end

  def result
    return @user if defined? @user

    @user = User.find_by(provider: @auth['provider'], email: @auth['info']['email'])
    if @user
      @user.update!(name: @auth['info']['name'])
    elsif @auth['provider'] == 'developer'
      @user = User.new(@auth['info'].to_hash.merge(provider: 'developer'))
    end
    @user
  end
end
