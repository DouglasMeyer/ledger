ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "capybara/rails"

Capybara::Screenshot.prune_strategy = :keep_last_run

#
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
require_relative "support/pages/base_page"
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Capybara.configure do |config|
  config.default_wait_time = 5
  config.default_driver = :webkit
  config.ignore_hidden_elements = false
end

SitePrism.configure do |config|
  config.use_implicit_waits = true
end

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
    Capybara.reset_sessions!
  end

  def mock_auth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new(
      provider: "developer",
      info: { name: "feature tester" }
    )
    yield
  ensure
    OmniAuth.config.mock_auth[:developer] = nil
  end

  config.around(:each, type: :feature) do |example|
    mock_auth do
      visit "/auth/developer"
      example.run
    end
  end

  config.around(:each, type: :request) do |example|
    mock_auth do
      get "/auth/developer"
      follow_redirect!
      example.run
    end
  end

  config.infer_spec_type_from_file_location!
end
