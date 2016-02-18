require 'rails_helper'

describe AccountEntry do
  describe ".join_aggrigate_account_entries" do
    it "includes balance_cents" do
      account = Account.make!
      a1 = AccountEntry.make! notes: 'A1', account: account, amount_cents: 1
      b1 = AccountEntry.make! notes: 'B1', amount_cents: 9
      a3 = AccountEntry.make! notes: 'A3', account: account, amount_cents: 30
      a2 = AccountEntry.make! notes: 'A2', account: account, amount_cents: 10
      a1.bank_entry.update_attribute :date, 4.days.ago
      b1.bank_entry.update_attribute :date, 3.days.ago
      a2.bank_entry.update_attribute :date, 2.days.ago
      a3.bank_entry.update_attribute :date, 1.day.ago

      expect(AccountEntry.join_aggrigate_account_entries.pluck('account_entries.id, aggrigate_account_entries.balance_cents').sort).to eq([
        [ a1.id, a1.amount_cents ],
        [ b1.id, b1.amount_cents ],
        [ a2.id, a1.amount_cents + a2.amount_cents ],
        [ a3.id, a1.amount_cents + a2.amount_cents + a3.amount_cents ]
      ].sort)
    end
  end
end
