Account.create! [
  { category: "Saving", name: "New Kitchen" },
  { category: "Saving", name: "New Computer" },

  { category: "Food", name: "Grocery" },
  { category: "Food", name: "Eat-out" },

  { category: "Transportation", name: "Gas" },
  { category: "Transportation", name: "Train" },

  { category: "Personal", name: "Hair Care" },
  { category: "Personal", name: "His Blow" },
  { category: "Personal", name: "Her Blow" },
  { category: "Personal", name: "Children" },
  { category: "Personal", name: "Clothing" },
  { category: "Personal", name: "Toiletries" },
  { category: "Personal", name: "Diapers" },

  { category: "Recreation", name: "Netflix" },
  { category: "Recreation", name: "Family Fun" },
  { category: "Recreation", name: "Baby Sitter" },
  { category: "Recreation", name: "Gym" },

  { category: "Charitable Gifts", name: "Missions", asset: false },
  { category: "Charitable Gifts", name: "Tithe", asset: false },
  { category: "Charitable Gifts", name: "Benevolence", asset: false },

  { category: "Loans", name: "Mortgage", asset: false },
  { category: "Loans", name: "Credit Card", asset: false },
  { category: "Loans", name: "His College", asset: false },
  { category: "Loans", name: "Her College", asset: false },
  { category: "Loans", name: "Car", asset: false },

  { category: "Utilities", name: "Electric", asset: false },
  { category: "Utilities", name: "Water", asset: false },
  { category: "Utilities", name: "Natural Gas", asset: false },
  { category: "Utilities", name: "Phone", asset: false },
  { category: "Utilities", name: "Trash", asset: false }
]

BankImport.create!(
  balance_cents: 1_450_00,
  created_at: 10.days.ago,
  updated_at: 10.days.ago
)
be = BankEntry.create!(
  date: 10.days.ago,
  amount_cents: 2_000_00,
  description: "Income",
  external_id: 1
)
be.account_entries.create! account_name: "Tithe",        amount: "200"
be.account_entries.create! account_name: "Missions",     amount: "200"
be.account_entries.create! account_name: "Benevolence",  amount: "20"

be.account_entries.create! account_name: "Mortgage",     amount: "500"
be.account_entries.create! account_name: "His College",  amount: "120"
be.account_entries.create! account_name: "Her College",  amount: "120"
be.account_entries.create! account_name: "Car",          amount: "50"

be.account_entries.create! account_name: "Gas",          amount: "90"

be.account_entries.create! account_name: "Electric",     amount: "60"
be.account_entries.create! account_name: "Water",        amount: "30"
be.account_entries.create! account_name: "Natural Gas",  amount: "35"
be.account_entries.create! account_name: "Phone",        amount: "100"
be.account_entries.create! account_name: "Trash",        amount: "5"

be.account_entries.create! account_name: "Grocery",      amount: "200"
be.account_entries.create! account_name: "Eat-out",      amount: "30"

be.account_entries.create! account_name: "Hair Care",    amount: "15"
be.account_entries.create! account_name: "His Blow",     amount: "15"
be.account_entries.create! account_name: "Her Blow",     amount: "15"
be.account_entries.create! account_name: "Children",     amount: "20"
be.account_entries.create! account_name: "Clothing",     amount: "5"
be.account_entries.create! account_name: "Toiletries",   amount: "5"
be.account_entries.create! account_name: "Diapers",      amount: "5"

be.account_entries.create! account_name: "Family Fun",   amount: "15"
be.account_entries.create! account_name: "Baby Sitter",  amount: "15"
be.account_entries.create! account_name: "Gym",          amount: "25"

be.account_entries.create! account_name: "New Kitchen",  amount: "65"
be.account_entries.create! account_name: "New Computer", amount: "40"

be = BankEntry.create!(
  date: 10.days.ago,
  amount_cents: -500_00,
  description: "Mortgage",
  external_id: 2
)
be.account_entries.create! account_name: "Mortgage", amount: "-500"

be = BankEntry.create!(
  date: 10.days.ago,
  amount_cents: -50_00,
  description: "Honda",
  external_id: 3
)
be.account_entries.create! account_name: "Car", amount: "-50"

BankImport.create!(
  balance_cents: 1_314_00_00,
  created_at: 4.days.ago,
  updated_at: 4.days.ago
)
be = BankEntry.create!(
  date: 6.days.ago,
  amount_cents: -80_00,
  description: "Local Shoppe",
  external_id: 4
)
be.account_entries.create! account_name: "Grocery", amount: "-60"
be.account_entries.create! account_name: "His Blow", amount: "-20"

be = BankEntry.create!(
  date: 5.days.ago,
  amount_cents: -56_00,
  description: "Gas King",
  external_id: 5
)
be.account_entries.create! account_name: "Gas", amount: "-56"

BankImport.create!(
  balance_cents: 1_299_00,
  created_at: 1.day.ago,
  updated_at: 1.day.ago
)
BankEntry.create!(
  date: 2.days.ago,
  amount_cents: -15_00,
  description: "Local Shoppe",
  external_id: 6
)
