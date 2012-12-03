namespace :accounts do

  desc 'Import accounts from budget export CSV'
  task :import => :environment do
    def from_money(money)
      money.gsub(/[^\d.-]/, '').to_f*100
    end

    require 'csv'
    csv = CSV.parse(File.read('/home/douglas/.local/Dropbox/Katy-Doug/budget.csv'))
# Account total... , _ , Category , Account , Balance, _ , Category , Account , Balance
    asset_category = ''
    liability_category = ''
    bank_entry = nil
    csv.each do |row|
      if row[0].present? && row[2].present? && bank_entry.nil?
        bank_entry = BankEntry.create! do |be|
          be.date = Date.today
          be.ammount_cents = from_money(row[1])
          be.description = 'Import from CSV'
        end
      end

      asset_category = row[2] unless row[2].blank?
      asset_account = row[3]
      asset_balance = row[4]

      liability_category = row[6] unless row[6].blank?
      liability_account = row[7]
      liability_balance = row[8]

      if asset_account.present?
        account = Account.create! asset: true, name: asset_account
        account.entries.create! ammount_cents: from_money(asset_balance),
                                bank_entry_id: bank_entry.id
      end

      if liability_account.present?
        account = Account.create! asset: false, name: liability_account
        account.entries.create! ammount_cents: from_money(liability_balance),
                                bank_entry_id: bank_entry.id
      end
    end
  end

end
