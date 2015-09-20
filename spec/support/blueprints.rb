require 'machinist/active_record'

Account.blueprint do
  name { "Account #{sn}" }
  asset { rand > 0.5 }
  position { sn }
end

BankEntry.blueprint do
  date { Date.today }
  amount_cents { (rand * 100_00 + 1).round / 100.0 * (rand > 0.5 ? 1 : -1) }
  description { "Bank entry #{sn}" }
  external_id { sn }
end

AccountEntry.blueprint do
  account { Account.make }
  bank_entry { BankEntry.make }
  amount_cents { object.bank_entry.amount_remaining * rand * 100 }
end

Strategy.blueprint do
  strategy_type { :fixed }
  variable { (rand * 200_00).round / 100.0 - 100 }
  notes { "Strategy ##{sn}" }
end

ProjectedEntry.blueprint do
  account { Account.make }
  amount_cents { (rand * 200_00).round / 100.0 - 100 }
  rrule { "FREQ=WEEKLY;DTSTART=#{Time.now.monday.next_week.utc.iso8601.remove('-').remove(':')}" }
end

BankImport.blueprint do
  balance_cents { (rand * 200_00).round / 100.0 - 100 }
end
