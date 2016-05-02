module API
  module LedgerSummary_v1
    def self.read(_command)
      latest_bank_import = ::BankImport
                           .order(created_at: :desc)
                           .first
      {
        data: {
          latest_bank_import: latest_bank_import,
          ledger_sum_cents: BankEntry.sum(:amount_cents)
        }
      }
    end
  end
end
