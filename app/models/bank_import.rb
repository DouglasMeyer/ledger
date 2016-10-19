require Rails.root + 'lib' + 'parse_statement'

class BankImport < ApplicationRecord
  def self.upload!(file)
    initial_import = BankImport.count.zero?
    bank_entry_attrs, balance = ParseStatement.run(file)
    balance_cents = balance.to_f * 100

    ActiveRecord::Base.transaction do
      if initial_import
        delta = balance_cents - bank_entry_attrs.sum{ |be| be[:amount_cents] }
        date = bank_entry_attrs.map { |be| be[:date] }.min
        BankEntry.create!(
          description: 'Balance on initial Ledger import.',
          amount_cents: delta,
          date: date
        )
      end

      bank_entry_attrs.compact.each do |be_attrs|
        unless BankEntry.where(external_id: be_attrs[:external_id].to_s).any?
          BankEntry.create! be_attrs
        end
      end

      BankImport.create! balance_cents: balance_cents
    end
  end
end
