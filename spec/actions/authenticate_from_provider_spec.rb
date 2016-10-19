require 'rails_helper'
# require_relative '../../app/actions/authenticate_from_provider'

describe AuthenticateFromProvider do
  let(:developer_auth) do
    OmniAuth::AuthHash.new(
      'provider' => 'developer', 'info' => {}
    )
  end
  let(:invalid_auth) do
    OmniAuth::AuthHash.new(
      'provider' => 'x', 'info' => {}
    )
  end
  let(:doug_auth) do
    OmniAuth::AuthHash.new(
      'provider' => 'google_oauth2', 'info' => {
        'email' => 'douglasyman@gmail.com',
        'name' => 'Douglas Meyer'
      }
    )
  end
  let(:doug_user) do
    User.create!(
      provider: doug_auth['provider'],
      email: doug_auth['info']['email'],
      ledger: 'template_ledger'
    )
  end

  describe '#success?' do
    it 'is true when provider is "developer"' do
      expect(AuthenticateFromProvider.new(developer_auth).success?).to be true
    end

    it 'is true when a User exists for provider/email' do
      doug_user
      expect(AuthenticateFromProvider.new(doug_auth).success?).to be true
    end

    it 'is false for auth that does not match' do
      expect(AuthenticateFromProvider.new(invalid_auth).success?).to be false
    end
  end

  describe '#result' do
    it 'is the user when successful' do
      doug_user
      expect(AuthenticateFromProvider.new(doug_auth).result).to eq doug_user
    end

    it 'updates user with name' do
      doug_user
      AuthenticateFromProvider.new(doug_auth).result
      expect(doug_user.reload.name).to eq 'Douglas Meyer'
    end

    it 'is nil when unsuccessful' do
      expect(AuthenticateFromProvider.new(invalid_auth).result).to be nil
    end
  end
end
