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
      @user = User.new(@auth['info'].merge(provider: 'developer').permit(:name, :ledger, :provider))
    end
    @user
  end
end
