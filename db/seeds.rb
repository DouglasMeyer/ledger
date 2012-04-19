ledger = Ledger.create! do |l|
  l.name = 'My Ledger'
end

harris = Ledger.create! do |l|
  l.name = 'Harris'
  l.bank = 'harris'
end

1.upto(5) do |n|
  harris.entries.create! do |e|
    e.date = n.days.ago
    e.description = "Entry #{n}"
    e.ammount = rand(100_00)/100.0 - 50
    e.external_id = n
  end
end

ledger.accounts.create!{|a| a.name = 'Tithe' }
ledger.accounts.create!{|a| a.name = 'Doug' }
ledger.accounts.create!{|a| a.name = 'Katy' }
ledger.accounts.create!{|a| a.name = 'Mortgage' }

entries = harris.entries.all
0.upto(3) do |n|
  ledger.entries.create! do |e|
    e.bank_entry = entries[n]
    e.date = Date.today
    e.ammount = entries[n].ammount
    e.account = ledger.accounts.order('RANDOM()').first
  end
end

entry = entries[4]
ledger.entries.create! do |e|
  e.bank_entry = entry
  e.date = Date.today
  e.ammount = entry.ammount / 2
  e.account = ledger.accounts.order('RANDOM()').first
end
ledger.entries.create! do |e|
  e.bank_entry = entry
  e.date = Date.today
  e.ammount = entry.ammount / 2
  e.account = ledger.accounts.order('RANDOM()').first
end
