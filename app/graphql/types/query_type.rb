module Types
  class QueryType < Types::BaseObject

    field :accounts, [AccountType], null: false do
      argument :relevant, GraphQL::Types::Boolean, required: false
    end
    def accounts(relevant: true)
      return Account.all unless relevant

      Account.all.select do |account|
        !account.balance_cents.zero? ||
        account.entries.where("updated_at > ?", 1.month.ago).any?
      end
    end

    field :bankEntries, [BankEntryType], null: false do
      # argument :relevant, GraphQL::Types::Boolean, required: false
    end
    def bank_entries
      BankEntry.all # .with_balance
    end

    field :projectedEntries, [ProjectedEntryType], null: false do
    end
    def projected_entries
      ProjectedEntry.all
    end

  end
end
