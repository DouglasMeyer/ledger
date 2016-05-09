require 'rails_helper'

describe AuthIsAdmin do
  let(:admin_auth){ { email: 'Douglas.Meyer@mail.com', provider: 'tester' } }
  before { ENV['ADMIN_AUTH'] = admin_auth.to_json }

  describe '#success?' do
    it 'is true when auth is a match' do
      expect(AuthIsAdmin.new(admin_auth).success?).to be true
    end

    it 'is false when auth is not a match' do
      expect(AuthIsAdmin.new({ email: 'Joe.Schmoe@mail.com', provider: 'tester' }).success?).to be false
    end
  end
end
