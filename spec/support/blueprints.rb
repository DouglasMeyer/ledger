require 'machinist/active_record'

Account.blueprint do
  name { "Account #{sn}" }
  asset { rand > 0.5 }
  position { sn }
end

BankEntry.blueprint do
  date { Date.today }
  ammount_cents { (rand * 200_00).round / 100.0 - 100 }
  description { "Bank entry #{sn}" }
  external_id { sn }
end

AccountEntry.blueprint do
  account { Account.make }
  bank_entry { BankEntry.make }
  ammount_cents { object.bank_entry.ammount_remaining * rand * 100 }
end
