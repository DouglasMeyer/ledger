require 'rails_helper'

describe BankImport do
  describe '.upload!' do
    it 'creates a BankEntry for initial balance' do
      entries = [{
        external_id: 100,
        date: 1.day.ago,
        amount_cents: 10_00,
        description: 'description'
      }]
      balance = 1_010.12
      expect(ParseStatement).to receive(:run).with('file').and_return([entries, balance])
      expect {
        BankImport.upload!('file')
      }.to change { BankEntry.count }.by 2

      expect(BankEntry.last.slice(:amount_cents, :description, :date)).to eq(
        'description' => 'Balance on initial Ledger import.',
        'amount_cents' => balance * 100 - 10_00,
        'date' => 1.day.ago.to_date
      )
    end
  end
end
