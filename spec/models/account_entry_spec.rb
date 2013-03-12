require File.expand_path '../../spec_helper', __FILE__

describe AccountEntry do
  describe ".join_aggrigate_account_entries" do
    it "includes balance_cents" do
      account = Account.make!
      ae1 = AccountEntry.make! account: account, ammount_cents: 1
      ae2 = AccountEntry.make! ammount_cents: 9
      ae3 = AccountEntry.make! account: account, ammount_cents: 10
      ae4 = AccountEntry.make! account: account, ammount_cents: 30

      AccountEntry.join_aggrigate_account_entries.pluck('account_entries.id, aggrigate_account_entries.balance_cents').sort.should eq([
        [ ae1.id, ae1.ammount_cents ],
        [ ae2.id, ae2.ammount_cents ],
        [ ae3.id, ae1.ammount_cents + ae3.ammount_cents ],
        [ ae4.id, ae1.ammount_cents + ae3.ammount_cents + ae4.ammount_cents ]
      ].sort)
    end
  end
end
