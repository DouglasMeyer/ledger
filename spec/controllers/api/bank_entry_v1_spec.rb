require 'rails_helper'

describe API::BankEntry_v1 do
  describe "read" do
    it "responds with collection" do
      BankEntry.make!
      AccountEntry.make!
      AccountEntry.make!

      response = API::BankEntry_v1.read({})
      expect(response[:records].pluck(:id, :balance_cents)).to eq(
        BankEntry.with_balance.pluck(:id, :balance_cents)
      )
      expect(response[:associated].pluck(:id)).to eq(
        AccountEntry.all.pluck(:id)
      )
    end

    it "paginates the response" do
      AccountEntry.make!
      BankEntry.make!
      AccountEntry.make!

      response = API::BankEntry_v1.read('limit' => 2)
      expect(response[:records].pluck(:id)).to eq(
        BankEntry.limit(2).pluck(:id)
      )
      expect(response[:associated].pluck(:id)).to eq(
        AccountEntry.last(1).map(&:id)
      )

      response = API::BankEntry_v1.read('limit' => 2, 'offset' => 2)
      expect(response[:records].pluck(:id)).to eq(
        BankEntry.last(1).map(&:id)
      )
      expect(response[:associated].pluck(:id)).to eq(
        AccountEntry.first(1).map(&:id)
      )
    end

    it "responds with entries needing distribution" do
      needs_distribution = []
      needs_distribution << BankEntry.make!
      BankEntry.make! amount_cents: 0
      needs_distribution << BankEntry.make!

      response = API::BankEntry_v1.read('needsDistribution' => true)
      expect(response[:records].pluck(:id)).to eq(
        BankEntry.with_balance.find(needs_distribution.map(&:id)).map(&:id)
      )
    end
  end

  describe "update" do
    it "updated bank_entry and associated account_entries" do
      bank_entry = AccountEntry.make!.bank_entry
      data = bank_entry.as_json
      data.delete('class_name')
      data.delete('account_entries')
      data['account_entries_attributes'] = bank_entry.account_entries.map(&:as_json)
      data['account_entries_attributes'][0].delete('class_name')

      data['notes'] = 'New Note'

      response = API::BankEntry_v1.update('id' => bank_entry.id, 'data' => data)

      bank_entry.reload
      expect(bank_entry.notes).to eq('New Note')
      expect(response[:records]).to eq([bank_entry])
    end

    it "removes account_entries with _destroy attribute" do
      bank_entry = AccountEntry.make!.bank_entry
      data = bank_entry.as_json
      data.delete('class_name')
      data.delete('account_entries')

      data['account_entries_attributes'] = [ { _destroy: true, id: bank_entry.account_entries.first.id } ]

      response = API::BankEntry_v1.update('id' => bank_entry.id, 'data' => data)

      bank_entry.reload
      expect(bank_entry.account_entries).to eq([])
    end
  end

  describe "create" do
    it "creates bank_entry and associated account_entries" do
      Account.make! name: 'Benevolence'
      Account.make! name: 'Fun Money'
      data = {
        date: '2014-08-23',
        amount_cents: 0,
        account_entries_attributes: [
          { account_name: 'Benevolence', amount_cents: -100_00 },
          { account_name: 'Fun Money',   amount_cents:  100_00 }
        ]
      }

      response = API::BankEntry_v1.create('data' => data)

      bank_entry = BankEntry.last
      expect(response[:records]).to eq([ bank_entry ])
      expect(response[:associated]).to eq(Account.all)
    end
  end

  describe "delete" do
    it "deletes bank_entry and associated account_entries" do
      bank_entry = BankEntry.make!(external_id: nil)
      account_entry = AccountEntry.make!(bank_entry: bank_entry)

      response = API::BankEntry_v1.delete('id' => bank_entry.id)

      expect(response[:records]).to be_empty
      expect { bank_entry.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { account_entry.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "preserves the bank_entry if it is from_bank?" do
      bank_entry = BankEntry.make!
      expect(bank_entry).to be_from_bank

      API::BankEntry_v1.delete('id' => bank_entry.id)
      bank_entry.reload
    end
  end
end
