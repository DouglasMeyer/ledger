Account.create! [
  { category: 'Saving', name: 'New Kitchen' },
  { category: 'Saving', name: 'New Computer' },

  { category: 'Food', name: 'Grocery' },
  { category: 'Food', name: 'Eat-out' },

  { category: 'Transportation', name: 'Gas' },
  { category: 'Transportation', name: 'Train' },

  { category: 'Personal', name: 'Hair Care' },
  { category: 'Personal', name: 'His Blow' },
  { category: 'Personal', name: 'Her Blow' },
  { category: 'Personal', name: 'Children' },
  { category: 'Personal', name: 'Clothing' },
  { category: 'Personal', name: 'Toiletries' },
  { category: 'Personal', name: 'Diapers' },

  { category: 'Recreation', name: 'Netflix' },
  { category: 'Recreation', name: 'Family Fun' },
  { category: 'Recreation', name: 'Baby Sitter' },
  { category: 'Recreation', name: 'Gym' },


  { category: 'Charitable Gifts', name: 'Missions', asset: false },
  { category: 'Charitable Gifts', name: 'Tithe', asset: false },
  { category: 'Charitable Gifts', name: 'Benevolence', asset: false },

  { category: 'Loans', name: 'Mortgage', asset: false },
  { category: 'Loans', name: 'Credit Card', asset: false },
  { category: 'Loans', name: 'His College', asset: false },
  { category: 'Loans', name: 'Her College', asset: false },
  { category: 'Loans', name: 'Car', asset: false },

  { category: 'Utilities', name: 'Electric', asset: false },
  { category: 'Utilities', name: 'Water', asset: false },
  { category: 'Utilities', name: 'Natural Gas', asset: false },
  { category: 'Utilities', name: 'Phone', asset: false },
  { category: 'Utilities', name: 'Trash', asset: false }
]

BankImport.create! balance_cents: 1_450_00, created_at: 10.days.ago, updated_at: 10.days.ago
be = BankEntry.create! date: 10.days.ago, ammount_cents: 2_000_00, description: 'Income', external_id: 1
be.account_entries.create! account_name: 'Tithe',       ammount: '200'
be.account_entries.create! account_name: 'Missions',    ammount: '200'
be.account_entries.create! account_name: 'Benevolence', ammount: '20'

be.account_entries.create! account_name: 'Mortgage',    ammount: '500'
be.account_entries.create! account_name: 'His College', ammount: '120'
be.account_entries.create! account_name: 'Her College', ammount: '120'
be.account_entries.create! account_name: 'Car',         ammount: '50'

be.account_entries.create! account_name: 'Gas',         ammount: '90'

be.account_entries.create! account_name: 'Electric',    ammount: '60'
be.account_entries.create! account_name: 'Water',       ammount: '30'
be.account_entries.create! account_name: 'Natural Gas', ammount: '35'
be.account_entries.create! account_name: 'Phone',       ammount: '100'
be.account_entries.create! account_name: 'Trash',       ammount: '5'

be.account_entries.create! account_name: 'Grocery',     ammount: '200'
be.account_entries.create! account_name: 'Eat-out',     ammount: '30'

be.account_entries.create! account_name: 'Hair Care',   ammount: '15'
be.account_entries.create! account_name: 'His Blow',    ammount: '15'
be.account_entries.create! account_name: 'Her Blow',    ammount: '15'
be.account_entries.create! account_name: 'Children',    ammount: '20'
be.account_entries.create! account_name: 'Clothing',    ammount: '5'
be.account_entries.create! account_name: 'Toiletries',  ammount: '5'
be.account_entries.create! account_name: 'Diapers',     ammount: '5'

be.account_entries.create! account_name: 'Family Fun',  ammount: '15'
be.account_entries.create! account_name: 'Baby Sitter', ammount: '15'
be.account_entries.create! account_name: 'Gym',         ammount: '25'

be.account_entries.create! account_name: 'New Kitchen', ammount: '65'
be.account_entries.create! account_name: 'New Computer',ammount: '40'


be = BankEntry.create! date: 10.days.ago, ammount_cents: -500_00, description: 'Mortgage', external_id: 2
be.account_entries.create! account_name: 'Mortgage', ammount: '-500'


be = BankEntry.create! date: 10.days.ago, ammount_cents: -50_00, description: 'Honda', external_id: 3
be.account_entries.create! account_name: 'Car', ammount: '-50'

BankImport.create! balance_cents: 1_314_00_00, created_at: 4.days.ago, updated_at: 4.days.ago
be = BankEntry.create! date: 6.days.ago, ammount_cents: -80_00, description: 'Local Shoppe', external_id: 4
be.account_entries.create! account_name: 'Grocery', ammount: '-60'
be.account_entries.create! account_name: 'His Blow', ammount: '-20'

be = BankEntry.create! date: 5.days.ago, ammount_cents: -56_00, description: 'Gas King', external_id: 5
be.account_entries.create! account_name: 'Gas', ammount: '-56'


BankImport.create! balance_cents: 1_299_00, created_at: 1.day.ago, updated_at: 1.day.ago
be = BankEntry.create! date: 2.days.ago, ammount_cents: -15_00, description: 'Local Shoppe', external_id: 6
