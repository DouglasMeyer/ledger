require "spec_helper"
require_relative "../../app/actions/authenticate_from_provider"

describe AuthenticateFromProvider do
  let(:developer_auth) { { "provider" => "developer" } }
  let(:doug_auth) do
    { "provider" => "google_oauth2", "info" => {
      "email" => "douglasyman@gmail.com"
    } }
  end
  let(:katy_auth) do
    { "provider" => "google_oauth2", "info" => {
      "email" => "kmeyer08@gmail.com",
      "name" => "Katy Meyer"
    } }
  end

  describe '#success?' do
    it 'is true when provider is "developer"' do
      expect(AuthenticateFromProvider.new(developer_auth).success?).to be true
    end

    it "is true when uid belongs to Doug" do
      expect(AuthenticateFromProvider.new(doug_auth).success?).to be true
    end

    it "is true when uid belongs to Katy" do
      expect(AuthenticateFromProvider.new(katy_auth).success?).to be true
    end

    it "is false for auth that does not match" do
      expect(AuthenticateFromProvider.new({}).success?).to be false
    end
  end

  describe '#result' do
    it "is the name when successful" do
      expect(AuthenticateFromProvider.new(katy_auth).result).to eq "Katy Meyer"
    end

    it "is nil when unsuccessful" do
      expect(AuthenticateFromProvider.new({}).result).to be nil
    end
  end
end
