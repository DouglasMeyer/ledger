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
          account_entries_attributes: {
            0 => { account_name: 'Doug Blow', ammount: '-8.00' },
            1 => { account_name: 'Grocery', ammount: '8.00' }
          }
        }

      bank_entry = BankEntry.last
      bank_entry.date.should eq(Date.civil(2013,2,13))
      bank_entry.account_entries.count.should eq(2)
      bank_entry.account_entries.first.ammount.should eq(-8)
      bank_entry.account_entries.first.account_name.should eq('Doug Blow')
    end
  end

end
