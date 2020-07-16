class Types::AccountType < Types::BaseObject
  # t.string "name", limit: 255, null: false
  # t.boolean "asset", default: true, null: false
  # t.datetime "created_at", null: false
  # t.datetime "updated_at", null: false
  # t.integer "position"
  # t.datetime "deleted_at"
  # t.integer "strategy_id"
  # t.string "category", limit: 255
  # t.index ["name"], name: "index_accounts_on_name", unique: true

  field :id, ID, null: false
  field :name, String, null: false
  # field :asset, Boolean, null: false
  field :balanceCents, Int, null: false
  # field :avatar, Types::PhotoType, null: true
end
