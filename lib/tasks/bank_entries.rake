namespace :bank_entries do

  desc 'Import bank entries from budget export CSV'
  task :import => :environment do
    def from_money(money)
      money = '0' if money.nil?
      (money.gsub(/[^\d.-]/, '').to_f*100).to_i
    end

    require 'csv'
    bank_entry = nil
    CSV.foreach('/home/douglas/.local/Dropbox/Katy-Doug/bank_entries.csv', headers: true) do |row|
      amount_cents = from_money(row['Credit']) - from_money(row['Debit'])

      if row['Date']
        month, day, year = row['Date'].scan(/\d+/).map(&:to_i)
        year += 2000 if year < 20
        date = Date.new(year, month, day)
        bank_entry = BankEntry.create! do |be|
          be.date          = date
          be.amount_cents = amount_cents
          be.notes         = row['Check #']
          be.description   = row['Description'] || ''
        end
      end

      if row['Category']
        account = Account.find_or_create_by_name!(row['Category'])
        account.entries.create! amount_cents: amount_cents,
                                bank_entry_id: bank_entry.id
      end

    end
  end

end
