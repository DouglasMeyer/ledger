class Types::ProjectedEntryType < Types::BaseObject
  field :id, ID, null: false
  field :account, Types::AccountType, null: false
  field :description, String, null: true
  field :amountCents, Int, null: false
  field :rrule, String, null: false

  # t.string "description", limit: 255
  # t.integer "amount_cents", null: false
  # t.string "rrule", limit: 255, null: false
end
