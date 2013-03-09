require File.expand_path '../../spec_helper', __FILE__

describe V2::BankEntriesController do

  describe "POST create" do
    it "creates a bank_entry and account_entries" do
      Account.make! name: 'Doug Blow'
      Account.make! name: 'Grocery'

      post :create,
        bank_entry: {
          date: '2013-02-13',
          description: 'test',
          account_entries_attributes: [
            { account_name: 'Doug Blow', ammount: '-8.00' },
            { account_name: 'Grocery',   ammount:  '8.00' }
          ]
        }

      bank_entry = BankEntry.last
      bank_entry.date.should eq(Date.civil(2013,2,13))
      bank_entry.account_entries.count.should eq(2)
      bank_entry.account_entries.first.ammount.should eq(-8)
      bank_entry.account_entries.first.account_name.should eq('Doug Blow')
    end
  end

  describe "PUT update" do
    it "updates the bank_entry and account_entries" do
      account = Account.make!
      bank_entry = BankEntry.make!
      first_ae = AccountEntry.make! bank_entry: bank_entry
      last_ae = AccountEntry.make! bank_entry: bank_entry

      put :update, id: bank_entry.id,
        bank_entry: {
          account_entries_attributes: [
            { id: first_ae.id, account_name: first_ae.account_name, ammount: "123.45" },
            { id: last_ae.id, account_name: last_ae.account_name, ammount: "6.78", _destroy: true },
            { account_name: account.name, ammount: "9.99" }
          ]
        }

      first_ae.reload
      first_ae.ammount.should eq(123.45)

      AccountEntry.where(id: last_ae.id).count.should eq(0)

      bank_entry.reload
      bank_entry.account_entries.count.should eq(2)
      bank_entry.account_entries.last.ammount.should eq(9.99)
    end
  end

end
