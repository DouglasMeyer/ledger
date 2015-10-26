require 'machinist/active_record'

# Account
Account.blueprint do
  name { "Account #{sn}" }
  asset { rand > 0.5 }
  position { sn }
end

Account.blueprint(:asset) do
  asset { true }
end

Account.blueprint(:liability) do
  asset { false }
end

# BankEntry
BankEntry.blueprint do
  date { Time.zone.today }
  amount_cents { (rand * 100_00 + 1).round / 100.0 * (rand > 0.5 ? 1 : -1) }
  description { "Bank entry #{sn}" }
  external_id { sn }
end

# AccountEntry
AccountEntry.blueprint do
  account { Account.make }
  bank_entry { BankEntry.make }
  amount_cents { object.bank_entry.amount_remaining * rand * 100 }
end

# Strategy
Strategy.blueprint do
  strategy_type { :fixed }
  variable { (rand * 200_00).round / 100.0 - 100 }
  notes { "Strategy ##{sn}" }
end

# ProjectedEntry
ProjectedEntry.blueprint do
  account { Account.make }
  amount_cents { (rand * 200_00).round / 100.0 - 100 }
  rrule do
    next_monday = Time.now.monday.next_week.utc.iso8601.remove('-').remove(':')
    "FREQ=WEEKLY;DTSTART=#{next_monday}"
  end
end

# BankImport
BankImport.blueprint do
  balance_cents { (rand * 200_00).round / 100.0 - 100 }
end
