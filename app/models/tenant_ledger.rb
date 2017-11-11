class TenantLedger
  class TenantLedgerError < StandardError ; end

  def self.all
    schemas = ActiveRecord::Base.connection.query("SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'").flatten
    schemas - %w( information_schema public )
  end

  def self.scope(ledger_name, &block)
    original_schema_earch_path = ActiveRecord::Base.connection.schema_search_path
    ActiveRecord::Base.connection.schema_search_path = "#{ledger_name},public"
    yield
  ensure
    ActiveRecord::Base.connection.schema_search_path = original_schema_earch_path
  end

  def self.create(ledger_name)
    original_verbose = ActiveRecord::Migration.verbose

    ActiveRecord::Base.connection.execute %{CREATE SCHEMA "#{ledger_name}"}
    scope(ledger_name) do
      ActiveRecord::Migration.verbose = false
      load Rails.root + 'db/tenant_schema.rb'
    end
  ensure
    ActiveRecord::Migration.verbose = original_verbose
  end

  def self.delete(ledger_name)
    raise TenantLedgerError, "#{ledger_name} is not a ledger" unless all.include? ledger_name
    ActiveRecord::Base.connection.execute %{DROP SCHEMA "#{ledger_name}" CASCADE}
  end
end
