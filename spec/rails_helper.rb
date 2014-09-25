ENV["RAILS_ENV"] ||= 'test'

require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
Dir[File.expand_path("../support/*.rb", __FILE__)].each { |file| require file }

# Checks for pending migrations before tests are run.
ActiveRecord::Migration.maintain_test_schema!

Capybara.configure do |config|
  config.default_wait_time = 5
  config.default_driver = ENV['DRIVER'] ? ENV['DRIVER'].to_sym : :webkit
  config.javascript_driver = ENV['JSDRIVER'] ? ENV['JSDRIVER'].to_sym : :selenium
  config.ignore_hidden_elements = false
end

SitePrism.configure do |config|
  config.use_implicit_waits = true
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end
end
