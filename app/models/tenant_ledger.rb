class TenantLedger
  class TenantLedgerError < StandardError ; end

  def self.all
    schemas = ActiveRecord::Base.connection.query("SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'").flatten
    schemas - %w( information_schema public )
  end

  def self.create(ledger_name)
    original_schema_earch_path = ActiveRecord::Base.connection.schema_search_path
    old_verbose = ActiveRecord::Migration.verbose

    ActiveRecord::Base.connection.execute %{CREATE SCHEMA "#{ledger_name}"}
    ActiveRecord::Base.connection.schema_search_path = ledger_name

    ActiveRecord::Migration.verbose = false
    load Rails.root + 'db/tenant_schema.rb'

  ensure
    ActiveRecord::Migration.verbose = old_verbose
    ActiveRecord::Base.connection.schema_search_path = original_schema_earch_path
  end

  def self.delete(ledger_name)
    raise TenantLedgerError, "#{ledger_name} is not a ledger" unless all.include? ledger_name
    ActiveRecord::Base.connection.execute %{DROP SCHEMA "#{ledger_name}" CASCADE}
  end
end
