source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '4.0.0.beta1'

gem 'pg'
gem 'haml'
gem 'simple_form'
gem 'bourbon'
gem 'capybara'
gem 'ngmin-rails'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0.beta1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-ui-rails'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

group :development, :test do
#  gem 'ruby-debug19', require:  'ruby-debug'
  gem 'debugger'
  gem 'rspec-rails'
  gem 'test_rails_js', '~> 0.1.2'

  gem "jasminerice", github: 'bradphelan/jasminerice'
end

group :development do
  gem 'net-netrc', require: false
  gem 'httparty', require: false
end

gem 'machinist', group: :test

gem 'sentry-raven', group: :production
