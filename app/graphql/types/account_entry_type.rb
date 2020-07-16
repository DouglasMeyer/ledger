class Types::AccountEntryType < Types::BaseObject
  field :id, ID, null: false
  field :account, Types::AccountType, null: false
  field :bankEntry, Types::BankEntryType, null: false
  field :amountCents, Int, null: false
  # t.text "notes"
  # t.datetime "created_at", null: false
  # t.datetime "updated_at", null: false
  # t.integer "strategy_id"
end
