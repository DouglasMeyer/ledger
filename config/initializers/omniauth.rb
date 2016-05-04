Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer, fields: [:name, :ledger] unless Rails.env.production?
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
end
