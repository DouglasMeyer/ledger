PartyFoul.configure do |config|
  # The collection of exceptions PartyFoul should not be allowed to handle
  # The constants here *must* be represented as strings
  config.blacklisted_exceptions = ["ActiveRecord::RecordNotFound", "ActionController::RoutingError"]

  # The OAuth token for the account that is opening the issues on GitHub
  config.oauth_token            = ENV["GITHUB_OAUTH_TOKEN"]

  # The API endpoint for GitHub. Unless you are hosting a private
  # instance of Enterprise GitHub you do not need to include this
  config.api_endpoint           = "https://api.github.com"

  # The Web URL for GitHub. Unless you are hosting a private
  # instance of Enterprise GitHub you do not need to include this
  config.web_url                = "https://github.com"

  # The organization or user that owns the target repository
  config.owner                  = "DouglasMeyer"

  # The repository for this application
  config.repo                   = "ledger"

  # The branch for your deployed code
  # config.branch               = 'master'

  # Setting your title prefix can help with
  # distinguising the issue between environments
  # config.title_prefix         = Rails.env
end
