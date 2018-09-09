class CreateLedgerTennantSchemas < ActiveRecord::Migration[4.2]
  PRIVATE_TABLES = %w(
    account_entries
    accounts
    bank_entries
    bank_imports
    projected_entries
    strategies
  )

  class User < ActiveRecord::Base ; end

  def up
    ledgers = User.distinct(:ledger).pluck(:ledger)
    ledgers = ['template_ledger'] if ledgers.empty?
    ledgers.each do |ledger|
      execute "CREATE SCHEMA #{ledger}"
      PRIVATE_TABLES.each do |table|
        execute "ALTER TABLE #{table} SET SCHEMA #{ledger}"
      end
    end
  end

  def down
    User.distinct(:ledger).pluck(:ledger).each do |ledger|
      ActiveRecord::Base.connection.schema_search_path = "#{ledger},public"
      PRIVATE_TABLES.each do |table|
        execute "ALTER TABLE #{table} SET SCHEMA public"
      end
      execute "DROP SCHEMA #{ledger}"
    end
  end
end
