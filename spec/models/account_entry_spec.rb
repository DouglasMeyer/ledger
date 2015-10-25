require 'rails_helper'

describe AccountEntry do
  describe '.join_aggrigate_account_entries' do
    it 'includes balance_cents' do
      account = Account.make!
      ae1 = AccountEntry.make! account: account, amount_cents: 1
      ae2 = AccountEntry.make! amount_cents: 9
      ae3 = AccountEntry.make! account: account, amount_cents: 10
      ae4 = AccountEntry.make! account: account, amount_cents: 30

      expect(AccountEntry.join_aggrigate_account_entries.pluck('account_entries.id, aggrigate_account_entries.balance_cents').sort).to eq([
        [ ae1.id, ae1.amount_cents ],
        [ ae2.id, ae2.amount_cents ],
        [ ae3.id, ae1.amount_cents + ae3.amount_cents ],
        [ ae4.id, ae1.amount_cents + ae3.amount_cents + ae4.amount_cents ]
      ].sort)
    end
  end
end
