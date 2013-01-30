require File.expand_path '../../spec_helper', __FILE__

describe Search do
  describe '.bank_entries' do
    it 'has bank_entries where ammount_remaining is equal to 0' do
      search = Search.new attribute: 'ammount_remaining', operator: 'is not equal to', ammount: '0'
      bank_entry1 = BankEntry.make! ammount_cents: 123_45
      bank_entry2 = BankEntry.make! ammount_cents: 200_00
      AccountEntry.make! bank_entry: bank_entry2, ammount_cents: 100_00
      be = BankEntry.make!
      AccountEntry.make! bank_entry: be, ammount_cents: be.ammount_cents

      expect(search.bank_entries.map(&:ammount_cents)).to eq([bank_entry1, bank_entry2].map(&:ammount_cents))
    end
  end
end
