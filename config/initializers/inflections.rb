# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  # inflect.acronym 'RESTful'
  inflect.acronym 'API'

end

Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect("api" => "API")

  autoloader.inflector.inflect(
    "account_v1" => "Account_v1",
    "bank_entry_v1" => "BankEntry_v1",
    "ledger_summary_v1" => "LedgerSummary_v1",
    "ledger_v1" => "Ledger_v1",
    "projected_entry_v1" => "ProjectedEntry_v1",
    "user_v1" => "User_v1"
  )
end

