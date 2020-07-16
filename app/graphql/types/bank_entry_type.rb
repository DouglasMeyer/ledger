class Types::BankEntryType < Types::BaseObject
  field :id, ID, null: false
  field :date, String, null: false
  field :amountCents, Int, null: false
  # t.text "notes"
  # t.string "description", limit: 255
  # t.string "external_id", limit: 255
  # t.datetime "created_at", null: false
  # t.datetime "updated_at", null: false

  field :accountEntries, [Types::AccountEntryType], null: false
end
