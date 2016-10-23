module API
  module BankEntry_v1
    extend Service

    def self.read(command)
      if command['needsDistribution'] == true
        records = ::BankEntry
                  .needs_distribution
                  .with_balance
        { records: records }
      else
        records = ::BankEntry
                  .with_balance
                  .limit(command['limit'] || 25)
                  .offset(command['offset'] || 0)
        account_entries = ::AccountEntry.where(bank_entry_id: records.pluck(:id))
        { records: records, associated: account_entries }
      end
    end

    def self.create(command)
      record = ::BankEntry.create!(command['data'])
      { records: [ record ], associated: record.accounts }
    end

    def self.update(command)
      record = ::BankEntry.find(command['id'])
      record.update!(command['data'])
      { records: [ record ], associated: record.accounts }
    end

    def self.delete(command)
      record = ::BankEntry.find(command['id'])
      record.account_entries.destroy_all
      record.destroy! unless record.from_bank?
      { records: [] }
    end
  end
end
