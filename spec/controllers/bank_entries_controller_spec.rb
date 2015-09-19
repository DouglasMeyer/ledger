require 'rails_helper'

describe V2::BankEntriesController do

  describe "GET index" do
    it "loads account_names" do
      Account.make! name: 'Last'
      Account.make! name: 'First'
      Account.make! name: 'Deleted', deleted_at: 1.minute.ago

      get :index
      expect(assigns(:account_names)).to eq(['First', 'Last'])
    end
  end

  describe "POST create" do
    it "creates a bank_entry and account_entries" do
      Account.make! name: 'Doug Blow'
      Account.make! name: 'Grocery'

      post :create,
           bank_entry: {
             date: '2013-02-13',
             description: 'test',
             account_entries_attributes: [
               { account_name: 'Doug Blow', amount: '-8.00' },
               { account_name: 'Grocery',   amount:  '6.00' },
               { account_name: '',          amount:  '2.00', '_destroy' => 'true' }
             ]
           }

      bank_entry = BankEntry.last
      expect(bank_entry.date).to eq(Date.civil(2013, 2, 13))
      expect(bank_entry.account_entries.count).to eq(2)
      expect(bank_entry.account_entries.first.amount).to eq(-8)
      expect(bank_entry.account_entries.first.account_name).to eq('Doug Blow')
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
                       { id: first_ae.id, account_name: first_ae.account_name, amount: "123.45" },
                       { id: last_ae.id, account_name: last_ae.account_name, amount: "6.78", _destroy: true },
                       { account_name: account.name, amount: "9.99" }
                     ]
                   }

      first_ae.reload
      expect(first_ae.amount).to eq(123.45)

      expect(AccountEntry.where(id: last_ae.id).count).to eq(0)

      bank_entry.reload
      expect(bank_entry.account_entries.count).to eq(2)
      expect(bank_entry.account_entries.last.amount).to eq(9.99)
    end
  end

end
