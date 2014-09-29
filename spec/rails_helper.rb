ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
#
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
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
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    # Use really fast transaction strategy for all
    # examples except `type: :feature` capybara specs
    DatabaseCleaner.strategy = example.metadata[:type] == :feature ? :truncation : :transaction

    # Start transaction
    DatabaseCleaner.start

    # Run example
    example.run

    # Rollback transaction
    DatabaseCleaner.clean

    # Clear session data
    Capybara.reset_sessions!
  end

  config.infer_spec_type_from_file_location!
end
