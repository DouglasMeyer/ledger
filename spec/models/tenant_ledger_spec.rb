require 'rails_helper'

describe TenantLedger do
  after do
    ActiveRecord::Base.connection.schema_search_path = 'template_ledger,public'
    extra_ledgers = TenantLedger.all - [ 'template_ledger' ]
    extra_ledgers.each{|ledger| TenantLedger.delete(ledger) }
  end

  describe '.all' do
    it 'returns all ledger names' do
      ActiveRecord::Base.connection.execute %{CREATE SCHEMA "fake_ledger"}

      expect(TenantLedger.all).to eq %w(template_ledger fake_ledger)
    end
  end

  describe '.create' do
    it 'creates a new ledger' do
      TenantLedger.create('new_ledger')

      expect(TenantLedger.all).to eq %w(template_ledger new_ledger)
    end

    it 'loads tenant schema' do
      Account.make!

      TenantLedger.create('new_ledger')

      ActiveRecord::Base.connection.schema_search_path = "new_ledger,public"
      expect(Account.count).to be 0
    end

    it 'restores original search path' do
      Account.make!

      TenantLedger.create('new_ledger')

      expect(Account.count).to be 1
    end
  end

  describe '.delete' do
    it 'removes ledger schemas' do
      TenantLedger.create('temp_ledger')
      TenantLedger.delete('temp_ledger')
      expect(TenantLedger.all).to eq %w(template_ledger)
    end

    it 'throws on non-ledger schemas' do
      expect {
        TenantLedger.delete('pg_catalog')
      }.to raise_error(TenantLedger::TenantLedgerError)
    end
  end
end
