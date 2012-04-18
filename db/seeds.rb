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

entries = harris.entries.all
0.upto(3) do |n|
  ledger.entries.create! do |e|
    e.bank_entry = entries[n]
    e.date = Date.today
    e.ammount = entries[n].ammount
    e.account = %w( Tithe Doug Katy Mortgage )[rand(4)]
  end
end

entry = entries[4]
ledger.entries.create! do |e|
  e.bank_entry = entry
  e.date = Date.today
  e.ammount = entry.ammount / 2
  e.account = %w( Tithe Doug Katy Mortgage )[rand(4)]
end
ledger.entries.create! do |e|
  e.bank_entry = entry
  e.date = Date.today
  e.ammount = entry.ammount / 2
  e.account = %w( Tithe Doug Katy Mortgage )[rand(4)]
end
