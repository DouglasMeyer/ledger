Rails.application.config.middleware.use OmniAuth::Builder do
  unless Rails.env.production?
    provider :developer,
      fields: [:name, :ledger],
      form: true
  end
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
end
