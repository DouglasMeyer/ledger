require Rails.root + 'lib' + 'parse_statement'

class BankImport < ActiveRecord::Base
  def self.upload!(file)
    bank_entry_attrs, balance = ParseStatement.run(file)

    ActiveRecord::Base.transaction do
      bank_entry_attrs.compact.each do |be_attrs|
        unless BankEntry.where(external_id: be_attrs[:external_id].to_s).any?
          BankEntry.create! be_attrs
        end
      end

      BankImport.create! balance_cents: balance.to_f * 100
    end
  end
end
